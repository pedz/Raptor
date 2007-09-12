module Retain
  class CallController < RetainController
    def show
      # parse the call spec.  It is the queue,center,h,ppg but the h
      # can be omitted.
      words = params[:call_spec].split(',')
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

      # This is reused so make a hash.
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
      else
        last_cached_page = 0
        last_cached_line_number = 0
        # Create a fresh PMR if we did not have one cached
        cached_pmr = Cached::Pmr.new(pmr_hash)
      end
      logger.debug("DEBUG: last_cached_page=#{last_cached_page}, last_cached_line_number=#{last_cached_line_number}")

      pmr_hash[:beginning_page_number] = last_cached_page if last_cached_page > 0
      @pmr = Retain::Pmr.new(pmr_hash)

      # Force the fetch of the PMR from Retain here.
      info_lines = @pmr.information_text_lines
      if info_lines.is_a?(Retain::TextLine)
        logger.debug("DEBUG: info_lines.class=#{info_lines.class}")
        if info_lines.text.blank?
          info_lines = []
        else
          info_lines = [ info_lines ]
        end
      else
        logger.debug("DEBUG: info_lines.length=#{info_lines.length}")
      end

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

      text_lines = @pmr.addtxt_lines
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

      new_text_lines = alt_lines + info_lines + text_lines

      if @pmr.beginning_page_number?
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
  end
end
