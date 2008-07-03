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
    end

    # Update the call
    def update
      @call = Combined::Call.from_param!(params[:id])
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
          
          if call_update[:add_time]
            psar_options = call_update[:psar_update].symbolize_keys
            psar_options.merge!(pmr_options)
            hours = psar_options.delete(:hours).to_i
            minutes = psar_options.delete(:minutes).to_i
            psar_options[:psar_actual_time] = (hours * 10) + (minutes / 6).to_i
            psar_options[:psar_chargeable_time] = hours * 256 + minutes
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
          need_undispatch = false
          undispatch = do_pmcu("NOCH", call_options)
          if undispatch.rc != 0
            render_error(undispatch, reply_span)
            rendered = true
            return
          end
          render(:update) { |page|
            page.replace_html reply_span, "<span class='sdi-error'>Not implemented yet... Sorry...</span>"
            page.visual_effect :fade, reply_span
          }
          
        when :close
          need_undispatch = false
          undispatch = do_pmcu("NOCH", call_options)
          if undispatch.rc != 0
            render_error(undispatch, reply_span)
            rendered = true
            return
          end
          render(:update) { |page|
            page.replace_html reply_span, "<span class='sdi-error'>Not implemented yet... Sorry...</span>"
            page.visual_effect :fade, reply_span
          }
          
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
      render(:update) { |page|
        page.replace_html reply_span, "Update Completed Successfully"
        page.visual_effect :fade, reply_span
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
            css_class, title, editable = @call.validate_next_queue(signon_user)
            render(:partial => "shared/retain/fixed_width_span",
                   :locals => {
                     :css_class => css_class,
                     :title => title,
                     :name => pmr.next_queue.nil? ? "blank" : pmr.next_queue.to_param,
                     :width => (Retain::Fields.field_width(:next_queue) + 1 # +1 for commma
                                Retain::Fields.field_width(:h_or_s) + 1 +
                                Retain::Fields.field_width(:next_center))
                   })
            return

            new_text = pmr.next_queue.to_param
            replace_text = "<span class='#{css_class}' title='#{title + ":Click to Edit"}'>#{new_text}</span>"

          when :pmr_owner_id
            pmr.mark_as_dirty
            css_class, title, editable = @call.validate_owner(signon_user)
            render(:partial => "shared/retain/fixed_width_span",
                   :locals => {
                     :css_class => css_class,
                     :title => title,
                     :name => pmr.owner.name,
                     :width => Retain::Fields.field_width(:pmr_owner_name)
                   })
            return

          when :pmr_resolver_id
            pmr.mark_as_dirty
            new_text = pmr.resolver.name
            css_class, title, editable = @call.validate_resolver(signon_user)
            replace_text = "<span class='#{css_class}' title='#{title + ":Click to Edit"}'>#{new_text}</span>"

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

    def render_error(sdi, area)
      err_text = sdi.error_message
      err_code = err_text[-3 ... err_text.length].to_i
        
      if (600 .. 700) === err_code
        err_class = "sdi-warning"
      else
        err_class = "sdi-error"
      end
      full_text = "<span class='#{err_class}'>#{err_text}</span>"
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
