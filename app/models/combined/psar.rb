# -*- coding: utf-8 -*-

module Combined
  class Psar < Base
    set_expire_time :check_mail_flag

    set_db_keys :psar_file_and_symbol
    add_skipped_fields :psar_file_and_symbol

    add_skipped_fields :pmr_id
    add_extra_fields :problem, :branch, :country, :customer_number

    add_skipped_fields :queue_id
    add_extra_fields :chargeable_queue_name, :chargeable_center

    add_skipped_fields :apar_id
    add_extra_fields :psar_apar
    
    add_skipped_fields :registration_id
    add_extra_fields :signon2

    def to_param
      psar_file_and_symbol
    end
    
    def check_mail_flag
      ret = (@cached && (@cached.psar_mailed_flag == "M") || @cached.updated_at > 12.hours.ago)
      # logger.debug("check_mail_flag for #{@cached.psar_file_and_symbol} is #{ret}")
      return ret
    end

    def self.fetch(search_hash)
      # Cuurently we do this in two steps.  We fetch just the "IRIS"s
      # and then we fetch the contents of each PSAR that is not in our
      # cache.
      search_hash = search_hash.dup
      search_hash[:group_request] = [ [ :psar_file_and_symbol ] ]
      begin
        de32s = Retain::Psar.new(search_hash).de32s
      rescue Retain::SdiReaderError => e
        raise e unless e.rc == 256
      else
        first_field = Combined::Psar.retain_fields.first
        de32s.each do |fields|
          combined = Combined::Psar.find_or_new :psar_file_and_symbol => fields.psar_file_and_symbol
          # Cause a touch
          combined.send first_field
        end
      end
    end

    # Returns the Saturday of the week that this PSAR applies to.
    def saturday
      t = Time.local(psar_stop_date_year.to_i,
                     psar_activity_date[0...2].to_i,
                     psar_activity_date[2...4].to_i)
      t -= 1.day until t.wday == 6
      t
    end
    once :saturday

    private
    
    def load
      if @cached.psar_mailed_flag == "M"
        # logger.debug("CMB: skipping load for #{self.to_s} -- mailed flag set to M")
        return
      end
      # logger.debug("CMB: load for #{self.to_param}")

      # Pull the fields we need from the cached record into an options_hash
      options_hash = { :psar_file_and_symbol => @cached.psar_file_and_symbol }

      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = [ group_request ]

      # Setup Retain object
      retain_object = self.class.retain_class.new(options_hash)

      # Special case for psar.
      begin
        psar = retain_object.de32
      rescue Retain::SdiReaderError => err
        # If the err.rc is 254, it means that the symbol was not
        # found.  If psar_mailed_flag is set but not set to "M", then
        # one of two things happened.  If the PSAR is old, retain
        # probably archived it and its no longer in Retain.  But if
        # the PSAR is new, someone may have deleted the PSAR.  So, we
        # test the psar_system_date which is the date that the PSAR
        # was created.  If the system date is before the previous
        # saturday, we assume Retain archived the PSAR.  In that case,
        # we flip the mailed flag to 'M' and keep the PSAR.  This
        # should be a very rare case.
        # Otherwise, we assume that someone deleted the PSAR and so we
        # delete it from the database.
        # logger.debug("mail flag is #{@cached.psar_mailed_flag}")
        if err.rc == 254 && @cached && @cached.psar_mailed_flag != nil
          # The purge date is the previous Saturday.
          purge_date = Time.now
          purge_date -= 1.day until purge_date.wday == 6
          purge_date -= 1.week
          purge_string = purge_date.strftime("%y%m%d")
          if @cached.psar_system_date < purge_string
            # logger.debug("Converting PSAR to mailed")
            @cached.psar_mailed_flag = "M"
            @cached.save!
          else
            # logger.debug("Destroying PSAR")
            @cached.destroy
          end
          return
        end
        raise err
      end

      # Make or find PMR
      # This is duplicate code ####
      pmr_options = {
        :problem => psar.problem,
        :branch  => psar.branch,
        :country => psar.country
      }
      @cached.pmr = Cached::Pmr.find_or_new(pmr_options)

      # Make or find customer
      cust_options = {
        :country => psar.country,
        :customer_number => psar.customer_number
      }
      @cached.pmr.customer = Cached::Customer.find_or_new(cust_options)
      
      # Hookup Queue
      # This is duplicate code ####
      center = Cached::Center.from_options(:center => psar.chargeable_center)
      if center
        center.save if center.new_record?
        @cached.center = center
        queue = center.queues.from_options(:queue_name => psar.chargeable_queue_name)
        if queue
          queue.save if queue.new_record?
          @cached.queue = queue
        end
      end

      # Update psar record
      options = self.class.cached_class.options_from_retain(psar)
      options[:dirty] = false if @cached.respond_to?("dirty")
      @cached.registration = Cached::Registration.find_or_initialize_by_psar_number(psar.signon2)
      @cached.updated_at = Time.now
      @cached.update_attributes(options)
    end
  end
end
