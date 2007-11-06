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

    #
    # I'm going to put a local copy of this here.  As the html view
    # changes, the fields needed should be added here.  I do not put
    # in the :alterable_format_text_lines here.  We request those only
    # sometimes and that field is appended if we want to receive them.
    #
    LOCAL_PMPB_GROUP_REQUEST = [
                                :queue_name,
                                :center,
                                :h_or_s,
                                :ppg,
                                :priority,
                                :severity,
                                :p_s_b,
                                :comments,
                                :customer_name,
                                :cstatus,
                                :nls_scratch_pad_1,
                                :nls_scratch_pad_2,
                                :nls_scratch_pad_3,
                                :nls_text_lines,
                                :pmr_owner_name,
                                :pmr_owner_employee_number,
                                :resolver_id,
                                :resolver_name,
                                :problem_e_mail
                               ].freeze
    
    def show
      # parse the call spec.  Format is: queue,center,h,ppg but the h
      # can be omitted.
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
      logger.info("#{@call.problem},#{@call.branch},#{@call.country}")

      # This is hash is reused so make a local variable.
      pmr_hash = {
        :problem => @call.problem,
        :branch => @call.branch,
        :country => @call.country
      }

      # Get the cached pmr if one exists.
      cached_pmr = Cached::Pmr.find(:first, :conditions => pmr_hash)

      # When we fetch the text lines from Retain, it pads with blank
      # lines up to the page boundary.
      
      if cached_pmr
        last_cached_line_number = cached_pmr.cached_text_lines.length
        last_cached_page = (last_cached_line_number / 16) + 1
      else
        page_offset = 0
        last_cached_page = 0
        last_cached_line_number = 0
        # Create a fresh PMR if we did not have one cached
        cached_pmr = Cached::Pmr.new(pmr_hash)
      end
      logger.info("DEBUG: last_cached_page=#{last_cached_page}, " +
                   "last_cached_line_number=#{last_cached_line_number}")

      if last_cached_page > 0
        pmr_hash[:beginning_page_number] = last_cached_page
      end
      @pmr = Retain::Pmr.new(pmr_hash)
      local_pmpb_group_request = LOCAL_PMPB_GROUP_REQUEST.dup

      # If the PMR is not in the cache, we request the FA lines;
      # otherwise we do not.
      if last_cached_page == 0
        local_pmpb_group_request << :alterable_format_text_lines
      end
      @pmr.pmpb_group_request = local_pmpb_group_request

      # Fetch the record from Retain here.
      text_lines = @pmr.nls_text_lines
      #
      # The way that the reply gunk works is a single text line will
      # have a value of just a single text line but a bunck of them
      # will be an array of text lines.  So, we test to see if
      # text_lines is a single element of type text line.  If it is,
      # we then check to see if it is blank; converting text_lines to
      # an empty element for a blank line and an array with a single
      # element in the other case.  We do the same thing later for
      # alt_lines.
      #
      if text_lines.is_a?(Retain::TextLine)
        logger.info("DEBUG: text_lines.class=#{text_lines.class}")
        if text_lines.text.blank?
          text_lines = []
        else
          text_lines = [ text_lines ]
        end
      else
        logger.info("DEBUG: text_lines.length=#{text_lines.length}")
      end

      # Some requests will not have the alterable format text so make
      # this conditional.  Becaues it is conditional, this can not be
      # the first thing we look at because it has not been fetched
      # yet.
      if @pmr.alterable_format_text_lines?
        logger.info("DEBUG: Received alt lines")
        alt_lines = @pmr.alterable_format_text_lines
        if alt_lines.is_a?(Retain::TextLine)
          logger.info("DEBUG: alt_lines.class=#{alt_lines.class}")
          if alt_lines.text.blank?
            alt_lines = []
          else
            alt_lines = [ alt_lines ]
          end
        else
          logger.info("DEBUG: alt_lines.length=#{alt_lines.length}")
        end
        #
        # The way an FA is displayed is that it consumes a multiple of
        # pages.  Here, we pad with blank lines to a page boundry.
        #
        mod = alt_lines.length % 16
        if mod != 0
          alt_lines += Retain::TextLine.blank_lines(16 - mod)
        end
      else
        alt_lines = []
      end

      # Retain puts the FA lines at the top.
      new_text_lines = alt_lines + text_lines

      if @pmr.beginning_page_number?
        # The minus 2 is because the first page of text on the screen
        # Retain calls Page 2.  We need a zero based index so the
        # multiplies come out right.  This should not be page_offset.
        beginning_page_number = @pmr.beginning_page_number - 2
        logger.info("DEBUG: @pmr.beginning_page_number = " +
                     "#{@pmr.beginning_page_number}")
        beginning_page_number = 0 if beginning_page_number < 0
      else
        beginning_page_number = 0
      end
      beginning_line_number = beginning_page_number * 16
      logger.info("DEBUG: beginning_page_number = #{beginning_page_number}")
      logger.info("DEBUG: first line: #{new_text_lines[0].text}")

      # For each line, we check to see if we already have it in the
      # cache.  If we do and it has not changed, we do nothing.  If it
      # is cached and it changes (from a blank line to a text line),
      # we modify the existing record.  If it is not cached, we create
      # a new line.
      cached_text_lines = cached_pmr.cached_text_lines
      new_text_lines.each_with_index do |line, index|
        line_number = beginning_line_number + index
        if last_cached_line_number > line_number
          cached_line = cached_text_lines[line_number]
          unless (cached_line.text == line.text &&
                  cached_line.line_type == line.line_type)
            logger.info("DEBUG: before: #{cached_line.line_number} " +
                         "#{cached_line.line_type} '#{cached_line.text}'")
            logger.info("DEBUG:  after: #{line_number} #{line.line_type} '" +
                         "#{line.text}'")
            cached_line.line_type = line.line_type
            cached_line.text = line.text
            cached_line.save!
          end
        else
          cached_text_line =
            Cached::TextLine.new(:line_number => line_number,
                                 :line_type   => line.line_type,
                                 :text        => line.text,
                                 :code_page   => line.code_page)
          cached_text_lines << cached_text_line
        end
      end
      cached_pmr.save!
      @text_lines = cached_pmr.cached_text_lines

      @ecpaat = Hash.new
      last_match = nil
      @text_lines.each do |line|
        # A signature or special line ends the match
        if line.line_type < 0x40
          logger.info("DEBUG: match end") if false
          last_match = nil
          next
        end
        if md = ECPAAT_REGEXP.match(line.text)
          logger.info("DEBUG: match start") if false
          last_match = md[1].downcase
          last_match = "environment" if last_match == "env"
          @ecpaat[last_match] = [ md[2] ]
          next
        end
        logger.info("DEBUG: match cont") if false
        @ecpaat[last_match] << line.text unless last_match.nil?
      end
      @ecpaat_lines = ""
      ECPAAT_HEADINGS.each do |head|
        @ecpaat_lines << "<b>#{head}:</b> "
        head_index = head.downcase
        if @ecpaat[head_index].nil?
          @ecpaat_lines << "<br/>"
        else
          add_blank = false
          @ecpaat[head_index].each do |line|
            if BLANK_REGEXP.match(line)
              add_blank = true
            else
              if add_blank
                @ecpaat_lines << "<br/>"
              end
              add_blank = false
              @ecpaat_lines << line + "<br/>"
            end
          end
        end
      end
    end

    def update
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
      pmpu.pmr_owner_employee_number = params[:pmr_owner_employee_number].gsub(/[\t ]/, '')
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      respond_to do |format|
        if pmpu.rc == 0
          format.html { render :text => params[:pmr_owner_employee_number] }
          format.xml  { logger.info("DEBUG: xml")  }
        else
          format.html { render(:text => params[:pmr_owner_employee_number],
                               :status => :unprocessable_entity) }
          format.xml  { logger.info("DEBUG: xml")  }
        end
      end
    end
  end
end
