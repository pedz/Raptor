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
      @call, @queue = Combined::Call.from_param_pair!(params[:id])
      @call.mark_cache_invalid
      @pmr = @call.pmr
      @pmr.mark_cache_invalid
      @psar = Psar.new(75, 57, 50, @pmr.severity, 9)
      
      # This is just for the button.  Probably needs to be removed
      # anyway
      @registration = signon_user
    end

    # Not used currently
    def update
    end

    def ct
      @call, @queue = Combined::Call.from_param_pair!(params[:id])
      pmr = @call.pmr
      options = @call.to_options

      # Three step process.  Dispatch, CT, Undispatch
      dispatch = do_pmcu("CD  ", options)
      logger.debug("dispatch rc = #{dispatch.rc}")
      if dispatch.rc != 0
        render_error(dispatch)
        return
      end

      ct = do_pmcu("CT  ", options)
      logger.debug("ct rc = #{ct.rc}")
      if ct.rc != 0
        render_error(ct)
        return
      end

      # At this point, the PMR has changed, so mark it as dirty
      pmr.mark_as_dirty
      
      undispatch = do_pmcu("NOCH", options)
      logger.debug("undispatch rc = #{undispatch.rc}")
      if undispatch.rc != 0
        render_error(undispatch)
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
      @call, @queue = Combined::Call.from_param_pair!(params[:id])
      pmr = @call.pmr
      field = params[:editorId].split('-')[1].to_sym
      new_text = params[:value]
      options = {
        :problem => pmr.problem,
        :branch => pmr.branch,
        :country => pmr.country,
      }
      case field
      when :next_queue
        new_queue_name, new_h_or_s, new_center = new_text.split(',')
        options[:next_queue] = new_queue_name.strip
        options[:next_center] = new_center
      else
        options[field] = new_text
      end

      # Perform the update.
      pmpu = Retain::Pmpu.new(options)
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      rc = pmpu.rc

      respond_to do |format|
        if rc == 0
          # Cause PMR to get reloaded from retain
          pmr.mark_as_dirty

          # Figure out what to send back
          case field
          when :next_queue
            new_text = pmr.next_queue.to_param
            css_class, title, editable = @call.validate_next_queue(signon_user)
          when :pmr_owner_id
            new_text = pmr.owner.name
            css_class, title, editable = @call.validate_owner(signon_user)
          when :pmr_resolver_id
            new_text = pmr.resolver.name
            css_class, title, editable = @call.validate_resolver(signon_user)
          end
          replace_text = "<span class='#{css_class}' title='#{title + ":Click to Edit"}'>#{new_text}</span>"
          format.html { render :text => replace_text }
        else
          format.html { render(:text => new_text,
                               :status => :unprocessable_entity) }
        end
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

    def render_error(sdi)
      err_text = sdi.error_message
      err_code = err_text[-3 ... err_text.length].to_i
        
      if (600 .. 700) === err_code
        err_class = "sdi-warning"
      else
        err_class = "sdi-error"
      end
      full_text = "<span class='#{err_class}'>#{err_text}</span>"
      render(:update) { |page|
        page.replace_html 'message-area', full_text
      }
    end
  end
end
