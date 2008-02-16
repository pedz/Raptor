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
    
    # Show a Retain call
    def show
      @call = Combined::Call.from_param(params[:id])
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
    
    def alter
      call = Combined::Call.from_param(params[:id])
      pmr = call.pmr
      field = params[:editorId].split('-')[1].to_sym
      new_text = params[:value]
      options = {
        :problem => pmr.problem,
        :branch => pmr.branch,
        :country => pmr.country,
        field => new_text
      }
      pmpu = Retain::Pmpu.new(options)
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      rc = pmpu.rc
      # new_text = "<span class='wag-wag'>banana</span>"
      # rc = 0
      respond_to do |format|
        if rc == 0
          # Cause PMR to get reloaded from retain
          pmr.mark_cache_invalid

          # Figure out what to send back
          case field
          when :pmr_owner_id
            new_owner = pmr.owner
            new_text = new_owner.name
            css_class, title, editable = call.validate_owner
            replace_text = "<span class='#{css_class}' title='#{title + ":Click to Edit"}'>#{new_text}</span>"
          when :pmr_resolver_id
            new_resolver = pmr.resolver
            new_text = new_resolver.name
            css_class, title, editable = call.validate_resolver
            replace_text = "<span class='#{css_class}' title='#{title + ":Click to Edit"}'>#{new_text}</span>"
          end
          format.html { render :text => replace_text }
          format.xml  { logger.info("RTN: xml")  }
        else
          format.html { render(:text => new_text,
                               :status => :unprocessable_entity) }
          format.xml  { logger.info("RTN: xml")  }
        end
      end
    end
  end
end
