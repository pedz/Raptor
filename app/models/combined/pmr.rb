module Combined
  class Pmr < Base
    add_skipped_fields :problem, :branch, :country, :owner_id, :resolver_id
    add_extra_fields :pmr_owner_id, :pmr_resolver_id

    set_expire_time 30.minutes

    def to_param
      pbc
    end

    def load
      logger.debug("CMB: load for <#{self.class.to_s}:#{"0x%x" % self.object_id}>")
      
      # Fields used for the lookup
      lookup_fields = %w{ problem branch country }
      
      # Pull the lookup fields into the options hash
      options_hash = Hash[ * lookup_fields.map { |field|
                             [ field.to_sym, @cached.attributes[field] ] }.flatten ]
      # We also need the signon and password but we get that from the
      # Logon singleton automatically.
      
      # We do the update in two steps hoping to save time and also
      # effort on Retain.  The first is to get just the time the PMR
      # was last altered.  This step is skipped if alteration_date (in
      # the cached entry) are nil.
      temp_id = "%s,%s,%s" % [ @cached.problem, @cached.branch, @cached.country ]
      if @cached.alteration_date
        logger.debug("CMB: #{temp_id} alteration date set")
        options_hash[:group_request] = [ :alteration_date, :alteration_time ]
        pmr = Retain::Pmr.new(options_hash)
        if (@cached.alteration_date == pmr.alteration_date) &&
            (@cached.alteration_time == pmr.alteration_time)
          logger.debug("CMB: #{temp_id} touched")
          @cached.save
          return
        end
        logger.debug("CMB: #{temp_id} has been altered")
      else
        logger.debug("CMB: #{temp_id} alteration date not set")
      end
      
      # PMPB uses group_request.  Lets create that:
      group_request_elements = Combined::Pmr.retain_fields.map { |field| field.to_sym }
      
      # Fields we need for the scratch pad, text_lines, etc.
      group_request_elements += [ :scratch_pad_signature,
                                  :nls_scratch_pad_1,
                                  :nls_scratch_pad_2, 
                                  :nls_scratch_pad_3,
                                  :alterable_format_lines,
                                  :nls_text_lines,
                                  :information_text_lines
                                ]
      
      if @cached.alteration_date
        fa_lines = @cached.alterable_format_lines.length
        text_lines = @cached.text_lines.length
        pages = (fa_lines + text_lines + 15) / 16
        logger.debug("CMB: #{temp_id} text_lines: #{text_lines}, fa_lines: #{fa_lines}, pages: #{pages}")
        options_hash[:beginning_page_number] = pages + 1
      end
      
      # Fields we need for the add text lines.
      options_hash[:group_request] = group_request_elements
      
      pmr = Retain::Pmr.new(options_hash)
      # Touch something to do the fetch from retain
      pmr.severity
      if @cached.alteration_date
        if pmr.nls_text_lines?
          logger.debug("CMB: #{temp_id} text_lines.length = #{pmr.nls_text_lines.length}")
        end
        if pmr.alterable_format_lines?
          logger.debug("CMB: #{temp_id} alterable_format_lines.length = #{pmr.alterable_format_lines.length}")
        end
      end
      # Create the alterable format text lines.  Need to do this
      # first so we can calculate the line offset for the text lines
      # properly
      if pmr.alterable_format_lines?
        update_lines(pmr.alterable_format_lines,
                     @cached.alterable_format_lines,
                     0,
                     Cached::TextLine::LineTypes::ALTERABLE_FORMAT)
      end
      
      # Create the text lines
      if pmr.nls_text_lines?
        if @cached.alteration_date
          offset = ((pmr.beginning_page_number - 2) * 16) - @cached.alterable_format_lines.length
        else
          offset = 0
        end
        update_lines(pmr.nls_text_lines,
                     @cached.text_lines,
                     offset,
                     Cached::TextLine::LineTypes::TEXT_LINE)
      end
      
      # Create the information text lines
      if pmr.information_text_lines?
        lines = pmr.information_text_lines
        lines = [ lines ] unless lines.kind_of? Array
        update_lines(lines,
                     @cached.information_text_lines,
                     0,
                     Cached::TextLine::LineTypes::INFORMATION_TEXT)
      end
      
      # Create the scratch pad lines
      lines = [ pmr.nls_scratch_pad_1,
                pmr.nls_scratch_pad_2,
                pmr.nls_scratch_pad_3,
                pmr.scratch_pad_signature ]
      update_lines(lines,
                   @cached.scratch_pad_lines,
                   0,
                   Cached::TextLine::LineTypes::SCRATCH_PAD)
      # Hook up owner and resolver
      owner = Cached::Registration.find_or_initialize_by_signon(pmr.pmr_owner_id)
      resolver = Cached::Registration.find_or_initialize_by_signon(pmr.pmr_resolver_id)
      @cached.owner = owner
      @cached.resolver = resolver
      # Update other attributes
      @cached.update_attributes(Cached::Pmr.options_from_retain(pmr))
    end

    # A convenience method to give back the usual form of
    # problem,branch,country for a call.
    def pbc
      (problem + "," + branch + "," + country).upcase
    end
    
    private

    # Merges pmr_lines into cached_lines.  Offset is the offset into
    # cached_lines to start the update.  line_type is the line_type of
    # the text line to create.
    def update_lines(pmr_lines, cached_lines, offset, line_type)
      raise "bad offset in update_lines" if cached_lines.length < offset
      logger.debug("CMB: Yes.... I'm getting called")
      pmr_lines.each_with_index do |line, index|
        line_number = offset + index
        text_line_options = {
          :line_number => offset + index,
          :line_type   => line_type,
          :text_type   => line.text_type,
          :text        => line.text
        }
        if cached_lines.length <= line_number
          cached_lines << Cached::TextLine.new(text_line_options)
        else
          logger.debug("CMB: possible update here")
          text_line = cached_lines[line_number]
          unless text_line_options.keys.select { |key|
              text_line_options[key] == text_line.send(key)
            }.empty?
            cached_lines[line_number].update_attributes(text_line_options) 
          end
        end
      end
    end
  end
end
