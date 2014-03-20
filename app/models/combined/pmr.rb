# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # === Combined PMR Model
  class Pmr < Combined::Base
    set_db_keys :problem, :branch, :country, :creation_date

    set_db_constants :problem, :branch, :country, :customer

    add_skipped_fields :owner_id
    add_extra_fields :pmr_owner_id, :pmr_owner_name

    add_skipped_fields :resolver_id
    add_extra_fields :pmr_resolver_id, :pmr_resolver_name

    add_skipped_fields :customer_id
    add_extra_fields   :customer_number

    add_skipped_fields :center_id, :queue_id, :primary, :center_name
    add_extra_fields   :center

    add_skipped_fields :next_center_id, :next_queue_id
    add_extra_fields   :next_center,    :next_queue

    add_skipped_fields :hot, :business_justification, :deleted

    ##
    # words is an array of string in the order: problem, branch,
    # country.  Returns an options has with :problem, :branch, and
    # :country as the keys.
    def self.words_to_options(words)
      raise Combined::PmrNotFound.new("%s,%s,%s" % [ words[0], words[1], words[2] ]) unless words.length == 3
      {
        :problem => words[0],
        :branch => words[1],
        :country => words[2]
      }
    end
    
    ##
    # signon user is not used.  Returns a PMR given a param string
    # whose format is PPPPP,BBB,CCC for problem, branch, and country.
    def self.from_param(param, signon_user = nil)
      create_from_options(retain_user_connection_parameters, param_to_options(param.upcase))
    end
    
    def self.from_param!(param, signon_user = nil)
      pmr = from_param(param, signon_user)
      if pmr.nil?
        raise PmrNotFound.new(param)
      end
      pmr
    end

    ##
    # This finds or creates a PMR that is not deleted.  entity must
    # respond to :problem, :branch, and :country (methods) and is
    # assumed to be a subclass of Retain so a fetch might occur and
    # this prevents the code from being in Cached::Pmr.
    #
    # This is called from the load method of other Combined entities
    # such as Call and Psar.  They do not know the creation date of
    # the PMR but this routine assumes that the PMR is valid in Retain
    # at the time of the call.  If it can not find a matching PMR, it
    # returns null (which I'm waffling about).
    def self.find_existing_pmr(entity)
      # This may cause a fetch from Retain if the entity is stale.
      pmr_options = {
          :problem => entity.problem,
          :branch  => entity.branch,
          :country => entity.country,
          :deleted => false
      }
      if (pmr = create_from_options(retain_user_connection_parameters, pmr_options))
        pmr = pmr.unwrap_to_cached
      end
      pmr
    end

    ##
    # Used by various Rails methods.  Usually the database id field is
    # returned.  For this model, we return the a string with
    # problem_branch_country (with underscores).
    def to_id
      (problem + '_' + branch + '_' + country).upcase
    end
    
    ##
    # Returns a string of problem,branch,country that is suitable to
    # be used as a param (last leg of a URL).
    def to_param
      pbc
    end

    ##
    # Returns the PMRs options has that contains :problem, :branch,
    # and :country as its keys.
    def to_options
      {
        :problem => problem,
        :branch => branch,
        :country => country
      }
    end
    
    ##
    # returns true for "Blue Diamond" PMRs
    def blue_diamand?
      hits = text_lines.find(:all,
                             :conditions => "text like '%XXBLUDXX%'")
      hits.length > 0
    end

    ##
    # returns true if PMR is entitled for USA Citizen support only.
    def usa_support_only?
      hits = information_text_lines.find(:all,
                                         :conditions => "text like '%SECURE SUPPORT VIA USA CITIZEN%'")
      logger.debug("usa_support_only? hits.length = #{hits.length}")
      hits.length > 0
    end

    private

    ##
    # load (fetch) the PMR and its associated text lines from Retain
    # and save it into the database.  The PMR is the only record in
    # Retain that has a last updated type of field in it.  This field
    # is called the :last_alter_timestamp.  The method of updating the
    # database is to first do a "quick" call to Retain to fetch just
    # that field.  If the PMR has not been updated in retain, we
    # update the updated_at field in the database to tell us when we
    # last check Retain and return.  Otherwise, we fetch any new text
    # lines and the other fields (changed or not) and save them to the
    # database.
    def load
      # logger.debug("CMB: load for #{self.to_param}")
      
      # Fields used for the lookup
      lookup_fields = %w{ problem branch country }
      
      # Pull the lookup fields into the options hash
      options_hash = Hash[ * lookup_fields.map { |field|
                             [ field.to_sym, @cached.attributes[field] ] }.flatten ]
      time_now = Time.now

      # We also need the signon and password but we get that from the
      # Logon singleton automatically.
      
      # We do the update in two steps hoping to save time and also
      # effort on Retain.  The first is to get just the time the PMR
      # was last altered.  This step is skipped if alteration_date (in
      # the cached entry) are nil.
      temp_id = "%s,%s,%s" % [ @cached.problem, @cached.branch, @cached.country ]
      if @cached.last_alter_timestamp
        # logger.debug("CMB: #{temp_id} last_alter_timestamp set")
        options_hash[:group_request] = [[ :last_alter_timestamp ]]
        pmr = Retain::Pmr.new(retain_user_connection_parameters, options_hash)
        begin
          not_used = pmr.last_alter_timestamp
        rescue Exception => e
          case
          when e.respond_to?(:sr) && e.sr == 115 && e.respond_to?(:ex) && e.ex == 125
            return
          else
            raise e
          end
        end
        
        if @cached.last_alter_timestamp == pmr.last_alter_timestamp
          # logger.debug("CMB: #{temp_id} touched")
          @cached.dirty = false
          @cached.updated_at = time_now
          @cached.save
          return
        end
        # logger.debug("CMB: #{temp_id} has been altered")
      else
        # logger.debug("CMB: #{temp_id} alteration date not set")
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
        options_hash[:beginning_page_number] = pages + 1
      end
      
      # Fields we need for the add text lines.
      options_hash[:group_request] = [ group_request_elements ]
      pmr = Retain::Pmr.new(retain_user_connection_parameters, options_hash)
      begin
	pmr.severity
      rescue Exception => e
        case
          # See if we get a "start page requested larger than last page of record"
          # If we do, then we purge the PMR and start back over.
        when e.sr == 115 && (e.ex >= 130 && e.ex <= 133)
	  @cached.text_lines.clear
          options_hash.delete(:beginning_page_number)
	  pmr = Retain::Pmr.new(retain_user_connection_parameters, options_hash)
	  pmr.severity

          # if the PMR has been deleted, we hit this.  We can have a
          # call pointing to this PMR so we don't want to mark the PMR
          # as deleted because that can cause us to create another PMR.
        when e.sr == 115 && e.ex == 125
          return

	else
	  raise e
	end
      end

      # if @cached.alteration_date
      #   if pmr.nls_text_lines?
      #     logger.debug("CMB: #{temp_id} text_lines.length = #{pmr.nls_text_lines.length}")
      #   end
      #   if pmr.alterable_format_lines?
      #     logger.debug("CMB: #{temp_id} alterable_format_lines.length = #{pmr.alterable_format_lines.length}")
      #   end
      # end

      # Create the alterable format text lines.  Need to do this
      # first so we can calculate the line offset for the text lines
      # properly
      if pmr.alterable_format_lines?
        update_lines(pmr.alterable_format_lines,
                     @cached.alterable_format_lines(true),
                     0,
                     Cached::TextLine::LineTypes::ALTERABLE_FORMAT)
        # Need to search for and parse the FAs to see if they have english = y.
        # EMEA and AP use FA 1654. Japan = FA 1659. Canada = FA 1514. LA = FA 1524
      end
      
      # Create the text lines
      if pmr.nls_text_lines?
        if pmr.has_key?(:beginning_page_number)
          offset = ((pmr.beginning_page_number - 2) * 16) - @cached.alterable_format_lines.length
	  offset = 0 if offset < 0
        else
          offset = 0
        end
        update_lines(pmr.nls_text_lines,
                     @cached.text_lines(true),
                     offset,
                     Cached::TextLine::LineTypes::TEXT_LINE)
      end
      
      # Create the information text lines
      if pmr.information_text_lines?
        lines = pmr.information_text_lines
        lines = [ lines ] unless lines.kind_of? Array
        update_lines(lines,
                     @cached.information_text_lines(true),
                     0,
                     Cached::TextLine::LineTypes::INFORMATION_TEXT)
      end
      
      # Create the scratch pad lines
      lines = [ pmr.nls_scratch_pad_1,
                pmr.nls_scratch_pad_2,
                pmr.nls_scratch_pad_3,
                pmr.scratch_pad_signature ]
      update_lines(lines,
                   @cached.scratch_pad_lines(true),
                   0,
                   Cached::TextLine::LineTypes::SCRATCH_PAD)

      # Hook up owner and resolver.  We have to plop in the name for
      # new records because we can not retrive all registrations.
      owner = Cached::Registration.find_or_initialize_by_signon_and_apptest(pmr.pmr_owner_id,
                                                                            retain_user_connection_parameters.apptest)
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
        resolver = Cached::Registration.find_or_initialize_by_signon_and_apptest(pmr.pmr_resolver_id,
                                                                                 retain_user_connection_parameters.apptest)
        resolver.name = pmr.pmr_resolver_name if resolver.name.nil?
        @cached.resolver = resolver
      end

      # Make or find customer
      cust_options = {
        :country => pmr.country,
        :customer_number => pmr.customer_number
      }
      customer = Cached::Customer.find_or_new(cust_options)
      customer.save if customer.new_record?
      @cached.customer = customer

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
      # logger.debug("CMB: primary_options = #{primary_options.inspect}")
      center = Cached::Center.create_from_options(retain_user_connection_parameters, primary_options)
      if center
        # logger.debug("CMB: got center")
        # We have to save the center if it is a new record.  This is
        # also true for the queue.  We are creating this complex
        # structure that is not flat.  The pmr points to the center,
        # queue, and primary call.  The queue points to the center,
        # and the call points to the queue.  During the save, if these
        # are new records, things get confused.
        center.save if center.new_record?
        @cached.center = center
        queue = center.queues.create_from_options(retain_user_connection_parameters, primary_options)
        if queue
          # logger.debug("CMB: got queue")
          queue.save if queue.new_record?
          @cached.queue = queue
          call = queue.calls.new_from_options(retain_user_connection_parameters, primary_options.merge({ :pmr_id => @cached.id }))
          if call
            # logger.debug("CMB: got call")
            if call.new_record?
              call.pmr = @cached
              call.save
            end
            @cached.primary_call = call
          else
            @cached.primary_call = nil
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
      nc = Cached::Center.from_options(retain_user_connection_parameters, nc_options)
      if nc
        nc.save if nc.new_record?
        @cached.next_center = nc
        nq = nc.queues.from_options(retain_user_connection_parameters, nc_options)
        if nq
          @cached.next_queue = nq
        end
      end

      #
      # Clean up the fields.  This piece cleans up the email address.
      retain_options = Cached::Pmr.options_from_retain(pmr)
      unless (email = retain_options[:problem_e_mail]).blank?
        addr_pattern = Regexp.new("^([^a-zA-Z0-9_.]*)([-a-zA-Z0-9_.]+@[-a-zA-Z0-9_.]+)([^a-zA-Z0-9_.]*)$")
        email = email.split(",").find_all { |addr|
          addr.match(addr_pattern)
        }.map { |addr|
          addr.sub(addr_pattern, '\2').sub(/[ _]+$/, "")
        }.join(',')
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
      retain_options[:dirty] = false
      retain_options[:last_fetched] = time_now
      retain_options[:updated_at] = time_now
      retain_options[:center_name] = pmr.center
      # logger.debug("PMR retain_options #{retain_options}")
      @cached.update_attributes(retain_options)
    end

    ##
    # Merges pmr_lines into cached_lines.  Offset is the offset into
    # cached_lines to start the update.  line_type is the line_type of
    # the text line to create.
    def update_lines(pmr_lines, cached_lines, offset, line_type)
      raise "bad offset in update_lines" if cached_lines.length < offset
      pmr_lines.each_with_index do |line, index|
        line_number = offset + index
        text_line_options = {
          :line_number => line_number,
          :line_type   => line_type,
          :text_type   => line.text_type,
          :text        => line.text
        }
        if cached_lines.length <= line_number
          begin
            cached_lines << Cached::TextLine.new(text_line_options)
          rescue => e
            Rails.logger.error("About to crap out: offset=#{offset}, length = #{cached_lines.length}, line_number = #{line_number}, last line number = #{cached_lines.last.line_number}")
            raise e
          end
        else
          # logger.debug("CMB: possible update here")
          text_line = cached_lines[line_number]
          if text_line_options.keys.any? { |key|
              if text_line_options[key] != text_line.send(key)
                # logger.debug("CMB: mismatch on #{key}: " +
                #              "'#{text_line_options[key]}' " +
                #              "!= '#{text_line.send(key)}'")
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
