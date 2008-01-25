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
      # id should be of the form queue_name,center,s,ppg
      # First, split id into a hash
      words = params[:id].split(',')
      options = {
        :queue_name => words[0],
        :center => words[1],
        :h_or_s => 'S',         # set default H/S field
      }
      options[:h_or_s] = words[2] if words.length == 4
      @queue = Combined::Queue.new(options)
      @call = @queue.calls.find_by_ppg(words.last)
      @pmr = @call.pmr
    end

    # Not used currently
    def update
    end
    
    def alter
      words = params[:id].split(',')
      options = {
        :queue_name => words[0],
        :center => words[1],
        :ppg => words.last
      }
      if words.length == 4
        options[:h_or_s] = words[2]
      end

      # Get the call from retain.  I'm afraid to cache these
      @call = Retain::Call.new(options)
      # This is hash is reused so make a local variable.
      pmr_hash = {
        :problem => @call.problem,
        :branch => @call.branch,
        :country => @call.country
      }
      pmpu = Retain::Pmpu.new(pmr_hash)
      if params[:pmr_owner_employee_number]
        new_text = pmpu.pmr_owner_employee_number =
          params[:pmr_owner_employee_number].gsub(/[\t ]/, '')
        logger.debug("RTN: owner = #{new_text}")
      elsif params[:resolver_id]
        new_text = pmpu.resolver_id = params[:resolver_id].gsub(/[\t ]/, '')
        logger.debug("RTN: resolver = #{new_text}")
      end
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      respond_to do |format|
        if pmpu.rc == 0
          format.html { render :text => new_text }
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
