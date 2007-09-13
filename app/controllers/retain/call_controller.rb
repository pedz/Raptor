module Retain
  class CallController < RetainController
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
                                :pmr_owner_employee_number
                               ]
    
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
      logger.debug("#{@call.problem},#{@call.branch},#{@call.country}")

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
        last_cached_page = (last_cached_line_number / 16)
        if (last_cached_page * 16) == last_cached_line_number
          page_offset = 1
        else
          page_offset = 2
        end
        last_cached_page += page_offset
      else
        page_offset = 0
        last_cached_page = 0
        last_cached_line_number = 0
        # Create a fresh PMR if we did not have one cached
        cached_pmr = Cached::Pmr.new(pmr_hash)
      end
      logger.debug("DEBUG: last_cached_page=#{last_cached_page}, last_cached_line_number=#{last_cached_line_number}")

      pmr_hash[:beginning_page_number] = last_cached_page if last_cached_page > 0
      @pmr = Retain::Pmr.new(pmr_hash)
      local_pmpb_group_request = LOCAL_PMPB_GROUP_REQUEST

      # If the PMR is not in the cache, we request the FA lines;
      # otherwise we do not.
      local_pmpb_group_request << :alterable_format_text_lines if last_cached_page == 0
      @pmr.pmpb_group_request = local_pmpb_group_request

      # Fetch the record from Retain here.
      text_lines = @pmr.nls_text_lines
      if text_lines.is_a?(Retain::TextLine)
        logger.debug("DEBUG: text_lines.class=#{text_lines.class}")
        if text_lines.text.blank?
          text_lines = []
        else
          text_lines = [ text_lines ]
        end
      else
        logger.debug("DEBUG: text_lines.length=#{text_lines.length}")
      end

      # Some requests will not have the alterable format text so make
      # this conditional.  Becaues it is conditional, this can not be
      # the first thing we look at because it has not been fetched
      # yet.
      if @pmr.alterable_format_text_lines?
        logger.debug("DEBUG: Received alt lines")
        alt_lines = @pmr.alterable_format_text_lines
        if alt_lines.is_a?(Retain::TextLine)
          logger.debug("DEBUG: alt_lines.class=#{alt_lines.class}")
          if alt_lines.text.blank?
            alt_lines = []
          else
            alt_lines = [ alt_lines ]
          end
        else
          logger.debug("DEBUG: alt_lines.length=#{alt_lines.length}")
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
        logger.debug("DEBUG: @pmr.beginning_page_number = #{@pmr.beginning_page_number}")
        beginning_page_number = 0 if beginning_page_number < 0
      else
        beginning_page_number = 0
      end
      beginning_line_number = beginning_page_number * 16
      logger.debug("DEBUG: beginning_page_number = #{beginning_page_number}")
      logger.debug("DEBUG: first line: #{new_text_lines[0].text}")

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
          unless cached_line.text == line.text && cached_line.line_type == line.line_type
            logger.debug("DEBUG: before: #{cached_line.line_number} #{cached_line.line_type} '#{cached_line.text}'")
            logger.debug("DEBUG:  after: #{line_number} #{line.line_type} '#{line.text}'")
            cached_line.line_type = line.line_type
            cached_line.text = line.text
            cached_line.save!
          end
        else
          cached_text_line = Cached::TextLine.new(:line_number => line_number,
                                                  :line_type   => line.line_type,
                                                  :text        => line.text)
          cached_text_lines << cached_text_line
        end
      end
      cached_pmr.save!
      @text_lines = cached_pmr.cached_text_lines
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
      pmpu.pmr_owner_employee_number = params[:pmr_owner_employee_number]
      fields = Retain::Fields.new
      pmpu.sendit(fields)
      respond_to do |format|
        if pmpu.rc == 0
          format.html { render :text => params[:pmr_owner_employee_number] }
          format.xml  { logger.debug("DEBUG: xml")  }
        else
          format.html { render(:text => params[:pmr_owner_employee_number],
                               :status => :unprocessable_entity) }
          format.xml  { logger.debug("DEBUG: xml")  }
        end
      end
    end
  end
end
