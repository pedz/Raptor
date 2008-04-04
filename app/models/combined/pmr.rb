module Combined
  class Pmr < Base
    set_expire_time 30.minutes

    set_db_keys :problem, :branch, :country
    add_skipped_fields :problem, :branch, :country

    set_db_constants :problem, :branch, :country, :customer

    add_skipped_fields :owner_id
    add_extra_fields :pmr_owner_id, :pmr_owner_name

    add_skipped_fields :resolver_id
    add_extra_fields :pmr_resolver_id, :pmr_resolver_name

    add_skipped_fields :customer_id
    add_extra_fields   :customer_number

    add_skipped_fields :center_id, :queue_id, :primary
    add_extra_fields   :queue_name, :center, :h_or_s, :ppg

    add_skipped_fields :next_center_id, :next_queue_id
    add_extra_fields   :next_center,    :next_queue

    def self.from_param(param)
      words = param.split(',')
      options = {
        :problem => words[0],
        :branch => words[1],
        :country => words[2]
      }
      find(:first, :conditions => options) || new(options)
    end

    def to_param
      pbc
    end

    # A convenience method to give back the usual form of
    # problem,branch,country for a call.
    def pbc
      (problem + "," + branch + "," + country).upcase
    end
    
    private

    def load
      logger.debug("CMB: load for #{self.to_s}")
      
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
        options_hash[:group_request] = [[ :alteration_date, :alteration_time ]]
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
      group_request_elements += [
                                 :scratch_pad_signature,
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
      options_hash[:group_request] = [ group_request_elements ]
      
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

      # Hook up owner and resolver.  We have to plop in the name for
      # new records because we can not retrive all registrations.
      owner = Cached::Registration.find_or_initialize_by_signon(pmr.pmr_owner_id)
      owner.name = pmr.pmr_owner_name if owner.name.nil?
      @cached.owner = owner

      # Special case... if the pmr_owner_id and the pmr_resolver_id
      # are both the same AND the owner is a new record, we need to
      # just point the resolver to the owner.  Otherwise, when the PMR
      # is saved, we try to create the same registration twice and we
      # die.  I decided to do this all the time which will save a db
      # hit.

      if pmr.pmr_owner_id == pmr.pmr_resolver_id
        @cached.resolver = owner
      else
        # Hook up resolver
        resolver = Cached::Registration.find_or_initialize_by_signon(pmr.pmr_resolver_id)
        resolver.name = pmr.pmr_resolver_name if resolver.name.nil?
        @cached.resolver = resolver
      end

      # Make or find customer
      cust_options = {
        :country => pmr.country,
        :customer_number => pmr.customer_number
      }
      @cached.customer = Cached::Customer.find_or_new(cust_options)

      # Make or find the primary call and its associated queue and center
      @cached.center = nil
      @cached.queue = nil
      @cached.primary = nil

      primary_options = {
        :center => pmr.center,
        :queue_name => pmr.queue_name,
        :h_or_s => pmr.h_or_s,
        :ppg => pmr.ppg
      }
      center_cmb = Combined::Center.from_options(primary_options)
      if center_cmb
        @cached.center = center_cmb.unwrap_to_cached
        queue_cmb = center_cmb.queues.from_options(primary_options)
        if queue_cmb
          @cached.queue = queue_cmb.unwrap_to_cached
          call_cmb = queue_cmb.calls.from_options(primary_options)
          if call_cmb
            @cached.primary = call_cmb.unwrap_to_cached
          end
        end
      end
      
      # Make or find next_center and next_queue
      @cached.next_center = nil
      @cached.next_queue = nil
      nc_options = {
        :center => pmr.next_center,
        :queue_name => pmr.next_queue,
        :h_or_s => pmr.h_or_s
      }
      nc_cmb = Combined::Center.from_options(nc_options)
      if nc_cmb
        @cached.next_center = nc_cmb.unwrap_to_cached
        nq_cmb = nc_cmb.queues.from_options(nc_options)
        if nq_cmb
          @cached.next_queue = nq_cmb.unwrap_to_cached
        end
      end

      #
      # Clean up the fields.  This piece cleans up the email address.
      retain_options = Cached::Pmr.options_from_retain(pmr)
      unless (email = retain_options[:problem_e_mail]).blank?
        addr_pattern = Regexp.new("^([^a-zA-Z0-9_.]*)([a-zA-Z0-9_.]+@[a-zA-Z0-9_.]+)([^a-zA-Z0-9_.]*)$")
        email = email.split(",").find_all { |addr|
          addr.match(addr_pattern)
        }.map { |addr|
          addr.sub(addr_pattern, '\2').sub(/[ _]+$/, "")
        }.join(', ')
        retain_options[:problem_e_mail] = email
      end

      # Clean up these fields to be upper case and stripped of blanks.
      %w{ sec_1_queue sec_1_center sec_1_h_or_s sec_1_ppg
          sec_2_queue sec_2_center sec_2_h_or_s sec_2_ppg
          sec_3_queue sec_3_center sec_3_h_or_s sec_3_ppg
        }.map(&:to_sym).each { |sym|
        unless (field = retain_options[sym]).nil?
          retain_options[sym] = field.upcase.strip
        end
      }

      # Update other attributes
      @cached.update_attributes(retain_options)
    end

    # Merges pmr_lines into cached_lines.  Offset is the offset into
    # cached_lines to start the update.  line_type is the line_type of
    # the text line to create.
    def update_lines(pmr_lines, cached_lines, offset, line_type)
      raise "bad offset in update_lines" if cached_lines.length < offset
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
          if text_line_options.keys.any? { |key|
              if text_line_options[key] != text_line.send(key)
                logger.debug("CMB: mismatch on #{key}: " +
                             "'#{text_line_options[key]}' " +
                             "!= '#{text_line.send(key)}'")
                true
              end
            }
            cached_lines[line_number].update_attributes(text_line_options) 
          end
        end
      end
    end
  end
end
