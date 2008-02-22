module Retain
  class CallController < RetainController
    ENVIRONMENT  = "environment|env".freeze
    CUSTOMER     = "customer rep".freeze
    PROBLEM      = "problem".freeze
    ACTION_TAKEN = "action taken".freeze
    ACTION_PLAN  = "action plan".freeze
    TESTCASE     = "testcase".freeze
    ECPAAT_HEADINGS = [ "Environment",
                        "Customer Rep",
                        "Problem",
                        "Action Taken",
                        "Action Plan",
                        "Testcase" ].freeze
    ECPAAT_REGEXP = Regexp.new("^(" +
                               "#{ENVIRONMENT}|" +
                               "#{CUSTOMER}|" +
                               "#{PROBLEM}|" +
                               "#{ACTION_TAKEN}|" +
                               "#{ACTION_PLAN}|" +
                               "#{TESTCASE}" +
                               "): *(.*)$", Regexp::IGNORECASE).freeze

    #
    # The Anderson tools puts a '.' on a line to create an empty line.
    # The regexp below is true if the whole line is blank or if the
    # initial character is a period followed by blanks.
    BLANK_REGEXP = Regexp.new("^[. ] *$").freeze
    
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
    
    # Show a Retain call
    def show
      @call, @queue = Combined::Call.from_param_pair(params[:id])
      @call.mark_cache_invalid
      @pmr = @call.pmr
      @pmr.mark_cache_invalid

      # This is just for the button.  Probably needs to be removed
      # anyway
      @registration =  Combined::Registration.default_user
    end

    # Not used currently
    def update
    end
    
    # Currently all the editable attributes that call PMPU fall into
    # this routine.  I might want to split it apart.  Not sure what to
    # do here.
    def alter
      @call, @queue = Combined::Call.from_param_pair(params[:id])
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
        new_queue_name, new_center, new_h_or_s = new_text.split(',')
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
          pmr.mark_cache_invalid

          # Figure out what to send back
          case field
          when :next_queue
            new_text = pmr.next_queue + "," + pmr.next_center
            css_class, title, editable = @call.validate_next_queue
          when :pmr_owner_id
            new_text = pmr.owner.name
            css_class, title, editable = @call.validate_owner
          when :pmr_resolver_id
            new_text = pmr.resolver.name
            css_class, title, editable = @call.validate_resolver
          end
          replace_text = "<span class='#{css_class}' title='#{title + ":Click to Edit"}'>#{new_text}</span>"
          format.html { render :text => replace_text }
          format.xml  { logger.info("RTN: xml")  }
        else
          format.html { render(:text => new_text,
                               :status => :unprocessable_entity) }
          format.xml  { logger.info("RTN: xml")  }
        end
      end
    end

    def queue_list
      @exception_json = [ "Call Not Found"].to_json
      @exception_type = :json
      call = Combined::Call.from_param(params[:id])
      queue = call.queue
      h_or_s = queue.h_or_s
      center = queue.center
      pmr_queues = []

      # owned_queues is a list of all the queues that have owners.
      owned_queues = Combined::QueueInfo.find(:all, :include => :queue).map { |qi|
        qi.queue.to_param
      }.uniq

      # team queues are queues in the same center that do not have an
      # owner.
      team_queues =
        Combined::Queue.find(:all,
                             :conditions => {
                               :center => center,
                               :h_or_s => h_or_s
                             },
                             :include => :queue_infos).select { |q|
        q.queue_infos.empty?
      }.map { |q|
        q.to_param
      }.sort

      # Walk through the signatures of the PMR adding to the pmr_queue
      # list only those not seen before and do not have owners.  Note
      # that I want to preseve order in the list so I can not use uniq
      # after the fact.
      call.pmr.signature_lines.each do |sig|
        if sig && (queue = sig.queue(h_or_s))
          unless pmr_queues.include?(queue) || owned_queues.include?(queue)
            pmr_queues << queue
          end
        end
      end
      result = pmr_queues.reverse + team_queues
      render :json => result.to_json
    end

  end
end
