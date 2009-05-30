module Retain
  class CallController < RetainController
    rescue_from Retain::SdiReaderError do |exception|
      raise exception unless exception.rc == 251
      case @exception_type
      when nil
        render :action => "not_found"
      when :text
        render :text => @exception_text
      when :json
        rendon :json => @exception_json
      end
    end
    
    Psar = Struct.new(:psar_service_code,
                      :psar_action_code,
                      :psar_cause,
                      :psar_impact,
                      :psar_solution_code,
                      :psar_actual_time,
                      :psar_chargeable_time,
                      :hours,
                      :minutes)
    
    # Show a Retain call
    def show
      @call = Combined::Call.from_param!(params[:id])
      @queue = @call.queue
      @call.mark_cache_invalid if @no_cache
      @pmr = @call.pmr
      @pmr.mark_cache_invalid if @no_cache
      # logger.debug("CNTRL: #{@pmr.updated_at} #{@pmr.etag}")
      fresh_when(:last_modified => @pmr.updated_at, :etag => @pmr.etag)
      # logger.debug("CNTRL: fresh? #{request.fresh?(response)}")
      # logger.debug("CNTRL: modified #{request.if_modified_since.inspect}")
      # logger.debug("CNTRL: none_match #{request.if_none_match.inspect}")
      # logger.debug("CNTRL: not_modified? #{request.not_modified?(response.last_modified)}")
      # logger.debug("CNTRL: etag_matchs? #{request.etag_matches?(response.etag)}")
      if !request.fresh?(response)
        # logger.debug("CNTRL: processing call...")
        @psar = Psar.new(75, 57, 50, @pmr.severity, 9)
      
        # This is just for the button.  Probably needs to be removed
        # anyway
        @registration = signon_user
        respond_to do |format|
          format.html # show.html.erb
          format.xml { render :xml => @call.to_xml(:include => { :pmr => { :include => :text_lines }}) }
        end
      end
    end

    # Update the call
    def update
      @call = Combined::Call.from_param!(params[:id])
      @queue = @call.queue
      call_options = @call.to_options
      @pmr = @call.pmr
      pmr_options = @pmr.to_options
      call_update = params[:retain_call_update].symbolize_keys
      
      # Convert the check box values to real true / false values.  I'm
      # worried I'm going to make a silly mistake if I don't.
      [ :do_ct, :do_ca, :add_time, :update_pmr ].each { |sym|
        if call_update.has_key?(sym)
          call_update[sym] = call_update[sym] == "1"
       else
         call_update[sym] = false
        end
       # logger.debug("#{sym} set to #{call_update[sym]}")
      }
      
      update_div = "call_update_div_#{@call.to_id}"
      reply_span = "call_update_reply_span_#{@call.to_id}"
      newtxt = format_lines(call_update[:newtxt])
      
      if call_update[:update_pmr]
        case call_update[:update_type]
          # We always set need_undispatch to be equal to
          # need_dispatch.  Some commands like requeue and close do
          # the undispatch as well.  But, in those cases, we set it to
          # false *after* the call has returned happy.  This allows
          # the ensure clause to undispatch the call when things
          # really go amuck.
        when "addtxt"
          update_type = :addtxt
          need_undispatch = need_dispatch = call_update[:do_ct]
        when "requeue"
          update_type = :requeue
          need_undispatch = need_dispatch = true
        when "dup"
          update_type = :dup
          need_undispatch = need_dispatch = call_update[:do_ct]
        when "close"
          update_type = :close
          need_undispatch = need_dispatch = true
        end
      else
        update_type = :none
        need_undispatch = need_dispatch = call_update[:do_ct]
      end
      
      do_fade = true
      text = ""
      begin
        if need_dispatch
          dispatch = do_pmcu("CD  ", call_options)
          if dispatch.rc != 0
            text = create_error_reply(dispatch, "Dispatch")
            raise
          end
        end

        if call_update[:do_ct]
          ct = do_pmcu("CT  ", call_options)
          if ct.rc != 0
            do_fade &= (ct.error_class == :error)
            text = create_error_reply(ct, "CT")
            raise
          end
          @pmr.mark_as_dirty
          text = create_reply_span("CT Completed")
        end
        
        case update_type
        when :addtxt
          addtxt_options = pmr_options.dup
          addtxt_options[:addtxt_lines] = newtxt unless newtxt.empty?
          addtxt = safe_new(Retain::Pmat, addtxt_options, reply_span)
          return if addtxt.nil?
          safe_sendit(addtxt)
          if addtxt.rc != 0
            do_fade &= (addtxt.error_class == :error)
            text += create_error_reply(addtxt, "Addtxt")
            raise
          end
          text += create_reply_span("ADDTXT Completed")
          @pmr.mark_as_dirty
          
          if call_update[:add_time]
            psar_options = get_psar_options(call_update)
            psar_options.merge!(pmr_options)
            psar = safe_new(Retain::Psrc, psar_options, reply_span)
            return if psar.nil?
            safe_sendit(psar)
            if psar.rc != 0
              do_fade &= (psar.error_class == :error)
              text += create_error_reply(psar, "PSAR")
            else
              text += create_reply_span("PSAR Added")
            end
          end
          
        when :requeue
          requeue_options = call_options.dup
          requeue_options[:addtxt_lines] = newtxt unless newtxt.empty?
          if call_update[:do_ca]
            requeue_options[:operand] = 'CA  '
          else
            requeue_options[:operand] = '    '
          end
          requeue_options.merge!(get_psar_options(call_update)) if call_update[:add_time]
          if (new_priority = call_update[:new_priority]) && @call.priority != new_priority
            requeue_options[:priority] = new_priority
            requeue_options[:severity] = new_priority
          end
          unless (sg = call_update[:service_given]).nil? || sg == "99"
            requeue_options[:service_given] = sg
          end
          from_team_to_personal = false
          # logger.debug("call_update[:do_ca] = #{call_update[:do_ca].inspect}")
          if call_update.has_key?(:new_queue) && !call_update[:do_ca]
            new_queue = Combined::Queue.from_param!(call_update[:new_queue])
            if new_queue.h_or_s != @queue.h_or_s
              if @queue.h_or_s == 'S' && new_queue.h_or_s == 'H' # from software to hardware
                requeue_options[:operand] = 'HW  '
              elsif @queue.h_or_s == 'H' && new_queue.h_or_s == 'S' # from hardware to software
                requeue_options[:operand] = 'SW  '
              else
                render(:update) { |page|
                  page.replace_html(reply_span,
                                    "<span class='sdi-error>" +
                                    "Can only requeue to and from software or hardware" +
                                    "</span>")
                  page.show area
                }
                return
              end
              # Note that the new h_or_s is not in the request.
            end
            requeue_options[:target_queue] = new_queue.queue_name
            if new_queue.center.center != @queue.center.center
              requeue_options[:target_center] = new_queue.center.center
            end

            # If queuing from a team queue to a personal queue

            if (@queue.team_queue? && !new_queue.team_queue? && @call.p_s_b == 'P')
              from_team_to_personal = true
              if @pmr.country == '000'
                # logger.debug("setting next queue")
                requeue_options[:next_queue] = @queue.queue_name
                requeue_options[:next_center] = @queue.center.center
              end
            end
          end

          requeue = safe_new(Retain::Pmcr, requeue_options, reply_span)
          return if requeue.nil?
          safe_sendit(requeue)

          # An error (and not just a warning) will leave us
          # dispatched.
          if requeue.rc == 0 || (600 .. 700) === requeue.rc
            # logger.debug("mark queue as dirty -- 1")
            @queue.mark_as_dirty
            @pmr.mark_as_dirty
            need_undispatch = false
          end

          if requeue.rc != 0
            do_fade &= (requeue.error_class == :error)
            text += create_error_reply(requeue, "Requeue")
          else
            text += create_reply_span("Requeue Completed")
            if from_team_to_personal
              # logger.debug("setting owner / resolver")
              alter_options = pmr_options.dup
              owner = new_queue.owners[0]
              alter_options[:pmr_resolver_id] = owner.signon
              if @pmr.country == '000'
                fields = "Owner & Resolver"
                alter_options[:pmr_owner_id] = owner.signon
              else
                fields = "Resolver"
              end
              alter = safe_new(Retain::Pmpu, alter_options, reply_span)
              raise "Create of PMR Alter Failed" if requeue.nil?
              safe_sendit(alter)
              if alter.rc != 0
                do_fade &= (alter.error_class == :error)
                text += create_error_reply(alter, "Alter")
              else
                text += create_reply_span("#{fields} Set")
              end
            end
          end
          
        when :dup
          dup_options = pmr_options.dup
          dup_options[:h_or_s] = @queue.h_or_s
          dup_options[:customer_number] = @pmr.customer.customer_number
          dup_options[:addtxt_lines] = newtxt unless newtxt.empty?
          dup_options[:comment] = @call.comments
          if new_queue = call_update[:new_queue]
            queue, h_or_s, center = new_queue.upcase.split(',')
            dup_options[:queue_name] = queue
            dup_options[:center] = center
          end
          dup = safe_new(Retain::Pmce, dup_options, reply_span)
          return if dup.nil?
          safe_sendit(dup)

          if dup.rc != 0
            do_fade &= (dup.error_class == :error)
            text += create_error_reply(dup, "Dup")
          else
            text += create_reply_span("Dup Completed")
          end
          
          if call_update[:add_time]
            psar_options = get_psar_options(call_update)
            psar_options.merge!(pmr_options)
            psar = safe_new(Retain::Psrc, psar_options, reply_span)
            return if psar.nil?
            safe_sendit(psar)
            if psar.rc != 0
              do_fade &= (psar.error_class == :error)
              text += create_error_reply(psar, "PSAR")
            else
              text += create_reply_span("PSAR Added")
            end
          end

        when :close
          close_options = call_options.dup
          close_options[:addtxt_lines] = newtxt unless @call.p_s_b == 'B' || newtxt.empty?
          close_options[:problem_status_code] = 'CL1L1 ' if @call.p_s_b == 'P'
          unless (sg = call_update[:service_given]).nil? || sg == "99"
            close_options[:service_given] = sg
          end
          close_options.merge!(get_psar_options(call_update)) if call_update[:add_time]
          close = safe_new(Retain::Pmcc,close_options, reply_span)
          return if close.nil?
          safe_sendit(close)
          
          # An error (and not just a warning) will leave us
          # dispatched.
          if close.rc == 0 || (600 .. 700) === close.rc
            # logger.debug("mark queue as dirty -- 2")
            @queue.mark_as_dirty
            @pmr.mark_as_dirty
            need_undispatch = false
          end

          if close.rc != 0
            do_fade &= (close.error_class == :error)
            text += create_error_reply(close, "Close")
          else
            text += create_reply_span("Close Completed")
          end
          
        when :none
          # Yes, this is duplicate code...  Not sure how to clean it up.
          if call_update[:add_time]
            psar_options = get_psar_options(call_update)
            psar_options.merge!(pmr_options)
            psar = safe_new(Retain::Psrc, psar_options, reply_span)
            return if psar.nil?
            safe_sendit(psar)
            if psar.rc != 0
              do_fade &= (psar.error_class == :error)
              text += create_error_reply(psar, "PSAR")
            else
              text += create_reply_span("PSAR Added")
            end
          end
        end
        
      rescue Exception => e
        unless e.nil?
          logger.error(e.backtrace_string)
          unless (msg = e.message).blank?
            text += create_reply_span(msg, :error)
          end
          do_fade = false
        end
        
      ensure
        
        if need_undispatch
          undispatch = do_pmcu("NOCH", call_options)
          if undispatch.rc != 0
            do_fade &= (undispatch.error_class == :error)
            text += create_error_reply(undispatch, "Undispatch")
          end
        end
      end
      render(:update) { |page|
        page.replace_html reply_span, text                          
        page.show reply_span
        if do_fade
          page.visual_effect(:fade, reply_span, :duration => 5.0)
          page[update_div].redraw
          page[update_div].close
        end
      }
    end

    def safe_new(klass, options, area)
      begin
        obj = klass.new(options)
      rescue ArgumentError => e
        text = create_reply_span(e.message, :error)
        render_message(text, area)
        return nil
      end
      return obj
    end
    
    def safe_sendit(obj)
      begin
        obj.sendit(Retain::Fields.new)
      rescue
        true
      end
    end

    def ct
      @call = Combined::Call.from_param!(params[:id])
      @queue = @call.queue
      pmr = @call.pmr
      options = @call.to_options

      # Three step process.  Dispatch, CT, Undispatch
      dispatch = do_pmcu("CD  ", options)
      if dispatch.rc != 0
        render_error(dispatch, 'message-area')
        return
      end

      ct = do_pmcu("CT  ", options)
      if ct.rc != 0
        render_error(ct, 'message-area')
        return
      end

      # At this point, the PMR has changed, so mark it as dirty
      pmr.mark_as_dirty
      
      undispatch = do_pmcu("NOCH", options)
      if undispatch.rc != 0
        render_error(undispatch, 'message-area')
        return
      end

      full_text = "<span class='sdi-normal'>CT completed successfully</span>"
      render(:update) { |page|
        page.replace_html 'message-area', full_text
        page.visual_effect :fade, 'message-area'
      }
    end

    # Currently all the editable attributes that call PMPU fall into
    # this routine.  I might want to split it apart.  Not sure what to
    # do here.
    def alter
      @call = Combined::Call.from_param!(params[:id])
      @queue = @call.queue
      pmr = @call.pmr
      # The field we are changing is the editor id which has the field
      # name with the call's id appended on separated with a '_'
      suffix_len = params[:id].length + 1
      field = params[:editorId][0...-suffix_len].to_sym
      new_text = params[:value]
      options = pmr.to_options

      case field
      when :next_queue
        new_queue_name, new_h_or_s, new_center = new_text.split(',')
        options[:next_queue] = new_queue_name.strip
        options[:next_center] = new_center
      when :comments
        options.merge!(@call.to_options)
        options[:comment] = new_text.gsub(/\A +/, '')
      else
        options[field] = new_text
      end
      # logger.debug("call alter options: #{options.inspect}")

      # Perform the update.
      pmpu = Retain::Pmpu.new(options)
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      rc = pmpu.rc

      respond_to do |format|
        if rc == 0
          # Cause PMR to get reloaded from retain

          # Figure out what to send back
          case field
          when :next_queue
            pmr.mark_as_dirty
            hash = @call.validate_next_queue(signon_user)
            self.extend Retain::RetainHelper
            fixed_width_span(hash)
            return

          when :pmr_owner_id
            pmr.mark_as_dirty
            hash = @call.validate_owner(signon_user)
            self.extend Retain::RetainHelper
            fixed_width_span(hash)
            return

          when :pmr_resolver_id
            pmr.mark_as_dirty
            hash = @call.validate_resolver(signon_user)
            self.extend Retain::RetainHelper
            fixed_width_span(hash)
            return

          when :comments
            @call.mark_as_dirty
            replace_text = @call.comments

          end
          format.html {
            # logger.debug("about to render replace_text")
            render :text => replace_text
          }
        else
          format.html {
            # logger.debug("about to render bad status")
            render :text => new_text, :status => :unprocessable_entity, :layout => false
          }
        end
        # logger.debug("all done with respond_to")
      end
    end

    def queue_list
      @exception_json = [ "Call Not Found"].to_json
      @exception_type = :json
      call = Combined::Call.from_param!(params[:id])
      if call.nil?
        render :json => nil
      end

      queue = call.queue
      center = queue.center
      personal_queues = center.queues.personal_queues.map(&:to_param)
      # logger.debug("call_controller: queue_list: personal_queues=#{personal_queues.inspect}")

      # Walk through the signatures of the PMR adding to the pmr_queue
      # list only those not seen before and do not have owners.  Note
      # that I want to preseve order in the list so I can not use uniq
      # after the fact.
      h_or_s = queue.h_or_s
      pmr_queues = []
      call.pmr.signature_lines.each do |sig|
        if sig && (queue = sig.queue(h_or_s))
          unless pmr_queues.include?(queue) || personal_queues.include?(queue)
            pmr_queues << queue
          end
        end
      end
      result = pmr_queues.reverse + center.queues.team_queues.map(&:to_param)
      render :json => result.to_json
    end

    private

    def get_psar_options(call_update)
      psar_options = call_update[:psar_update].symbolize_keys
      # Pull out the "SAC" and convert to Service, Action, Cause
      sac = Retain::ServiceActionCauseTuple.find(psar_options.delete(:sac).to_i)
      psar_options[:psar_service_code] = sac.psar_service_code
      psar_options[:psar_action_code] = sac.psar_action_code
      psar_options[:psar_cause] = sac.psar_cause

      # Amount of time spent
      hours   = psar_options.delete(:hours).to_i
      minutes = psar_options.delete(:minutes).to_i

      # Stop time and date
      year    = psar_options.delete(:stop_year).to_i
      month   = psar_options.delete(:stop_month).to_i
      day     = psar_options.delete(:stop_day).to_i
      hour    = psar_options.delete(:stop_hour).to_i
      minute  = psar_options.delete(:stop_minute).to_i

      # Munge the psar_options that we need to munge
      psar_options[:psar_actual_time] = (hours * 10) + (minutes / 6).to_i
      psar_options[:psar_chargeable_time] = hours * 256 + minutes
      if psar_options[:alter_time] == "1"
        psar_options[:local_stop_date] =
          format("%02d/%02d/%02d", month, day, year % 100)
        psar_options[:psar_activity_stop_time] =
          format("%02d%1d", hour, minute / 6)
      end
      psar_options
    end

    def do_pmcu(cmd, options)
      options = { :operand => cmd }.merge(options)
      pmcu = Retain::Pmcu.new(options)
      begin
        pmcu.sendit(Retain::Fields.new)
      rescue
        true
      end
      return pmcu
    end

    def create_reply_span(msg, error_class = :normal)
      span_class = "sdi-#{error_class.to_s}"
      ApplicationController.helpers.content_tag :span, msg + ". ", :class => span_class
    end

    def create_error_reply(sdi, request)
      err_text = "#{request}: #{sdi.error_message}"
      create_reply_span(err_text, sdi.error_class)
    end
    
    def render_error(sdi, area, request)
      render_message(create_error_reply(sdi, request), area)
    end

    def render_message(msg, area)
      render(:update) { |page|
        page.replace_html area, msg
        page.show area
      }
    end

    def format_lines(lines)
      return nil if lines.nil?
      lines.split("\n").map { |line|
        l = []
        while line.length > 72
          this_end = 72
          while this_end > 0 && line[this_end] != 0x20
            this_end -= 1
          end
          if this_end == 0      # no spaces found
            l << line[0 ... 72]
            line = line[72 ... line.length]
            next
          end
          
          new_start = this_end + 1
          while new_start < line.length && line[new_start] == 0x20
            new_start += 1
          end
          l << line[0 ... this_end]
          line = line[new_start ... line.length]
        end
        l << line
        l
      }.flatten
    end
  end
end
