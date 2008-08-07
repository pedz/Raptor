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
                      :psar_solution,
                      :psar_actual_time,
                      :psar_chargeable_time,
                      :hours,
                      :minutes)
    
    # Show a Retain call
    def show
      @call = Combined::Call.from_param!(params[:id])
      @queue = @call.queue
      @call.mark_cache_invalid
      @pmr = @call.pmr
      @pmr.mark_cache_invalid
      @psar = Psar.new(75, 57, 50, @pmr.severity, 9)
      
      # This is just for the button.  Probably needs to be removed
      # anyway
      @registration = signon_user
      respond_to do |format|
        format.html # show.html.erb
        format.xml { render :xml => @call.to_xml(:include => { :pmr => { :include => :text_lines }}) }
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
      [ :do_ct, :add_time, :update_pmr ].each { |sym|
        if call_update.has_key?(sym)
          call_update[sym] = call_update[sym] == "1"
        end
      }
      
      form = "call_update_form_#{@call.to_id}"
      reply_span = "call_update_reply_span_#{@call.to_id}"
      newtxt = format_lines(call_update[:newtxt])
      
      if call_update[:update_pmr]
        case call_update[:update_type]
        when "addtxt"
          update_type = :addtxt
          need_undispatch = need_dispatch = call_update[:do_ct]
        when "requeue"
          update_type = :requeue
          need_dispatch = true
          need_undispatch = false
        when "close"
          update_type = :close
          need_dispatch = true
          need_undispatch = false
        end
      else
        update_type = :none
        need_undispatch = need_dispatch = call_update[:do_ct]
      end
      
      if need_dispatch
        dispatch = do_pmcu("CD  ", call_options)
        if dispatch.rc != 0
          render_error(dispatch, reply_span)
          return
        end
      end
      
      rendered = false
      begin
        if call_update[:do_ct]
          ct = do_pmcu("CT  ", call_options)
          if ct.rc != 0
            render_error(ct, reply_span)
            rendered = true
            return
          end
          @pmr.mark_as_dirty
        end
        
        case update_type
        when :addtxt
          addtxt_options = pmr_options.dup
          addtxt_options[:addtxt_lines] = newtxt
          addtxt = Retain::Pmat.new(addtxt_options)
          begin
            addtxt.sendit(Retain::Fields.new)
          rescue
            true
          end
          if addtxt.rc != 0
            render_error(addtxt, reply_span)
            rendered = true
            return
          end
          @pmr.mark_as_dirty
          
          if call_update[:add_time]
            psar_options = get_psar_options(call_update)
            psar_options.merge!(pmr_options)
            psar = Retain::Psrc.new(psar_options)
            begin
              psar.sendit(Retain::Fields.new)
            rescue
              true
            end
            if psar.rc != 0
              render_error(psar, reply_span)
              rendered = true
              return
            end
          end
          
        when :requeue
          requeue_options = call_options.dup
          requeue_options[:addtxt_lines] = newtxt
          requeue_options[:operand] = '    '
          requeue_options.merge!(get_psar_options(call_update)) if call_update[:add_time]
          if (new_priority = call_update[:new_priority]) && @call.priority != new_priority
            requeue_options[:priority] = new_priority
            requeue_options[:severity] = new_priority
          end
          
          if new_queue = call_update[:new_queue]
            queue, h_or_s, center = new_queue.upcase.split(',')
            if h_or_s != @queue.h_or_s
              if @queue.h_or_s == 'S' && h_or_s == 'H' # from software to hardware
                requeue_options[:operand] = 'HW  '
              elsif @queue.h_or_s == 'H' && h_or_s == 'S' # from hardware to software
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
            requeue_options[:target_queue] = queue
            if center != @queue.center.center
              requeue_options[:target_center] = center
            end
          end
          requeue = Retain::Pmcr.new(requeue_options)
          begin
            requeue.sendit(Retain::Fields.new)
          rescue
            true
          end
          
          # This is a guess for now.  An error (and not just a
          # warning) will leave us dispatched.
          if requeue.rc == 0 || (600 .. 700) === requeue.rc
            logger.debug("mark queue as dirty -- 1")
            @queue.mark_as_dirty
          else
            need_undispatch = true
          end

          if requeue.rc != 0
            render_error(requeue, reply_span)
            rendered = true
            return
          end
          
        when :close
          close_options = call_options.dup
          close_options[:addtxt_lines] = newtxt if @call.p_s_b != 'B'
          close_options[:problem_status_code] = 'CL1L1 ' if @call.p_s_b == 'P'
          close_options.merge!(get_psar_options(call_update)) if call_update[:add_time]
          close = Retain::Pmcc.new(close_options)
          begin
            close.sendit(Retain::Fields.new)
          rescue
            true
          end
          
          # This is a guess for now.  An error (and not just a
          # warning) will leave us dispatched.
          if close.rc == 0 || (600 .. 700) === close.rc
            logger.debug("mark queue as dirty -- 2")
            @queue.mark_as_dirty
          else
            need_undispatch = true
          end

          if close.rc != 0
            render_error(close, reply_span)
            rendered = true
            return
          end
          
        when :none
        end
        
      ensure
        
        if need_undispatch
          undispatch = do_pmcu("NOCH", call_options)
          if undispatch.rc != 0
            render_error(undispatch, reply_span) unless rendered
            return
          end
        end
      end
      text = create_reply_span("Update Completed Successfully", 0)
      render(:update) { |page|
        page.replace_html reply_span, text                          
        page.visual_effect :fade, reply_span, :duration => 2.0
        page[form].reset
      }
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
      logger.debug("call alter options: #{options.inspect}")

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
            logger.debug("about to render replace_text")
            render :text => replace_text
          }
        else
          format.html {
            logger.debug("about to render bad status")
            render :text => new_text, :status => :unprocessable_entity, :layout => false
          }
        end
        logger.debug("all done with respond_to")
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
      logger.debug("call_controller: queue_list: personal_queues=#{personal_queues.inspect}")

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
      psar_options[:local_stop_date] = format("%02d/%02d%02d", year % 100, month, day)
      psar_options[:psar_activity_stop_time] = format("%02d%1d", hour, minute / 6)
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

    def create_reply_span(msg, rc)
      case rc
      when 0; span_class = 'sdi-normal'
      when 600 .. 700; span_class = 'sdi-warning'
      else span_class = 'sdi-error'
      end
      ApplicationController.helpers.content_tag :span, msg, :class => span_class
    end

    def create_error_reply(sdi)
      err_text = sdi.error_message
      err_code = err_text[-3 ... err_text.length].to_i
      create_reply_span(err_text, err_code)
    end
    
    def render_error(sdi, area)
      full_text = create_error_reply(sdi)
      render(:update) { |page|
        page.replace_html area, full_text
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
