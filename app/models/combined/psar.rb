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
    
    def to_param
      psar_file_and_symbol
    end
    
    def check_mail_flag
      return @cached && @cached.psar_mailed_flag == "M"
    end

    def load
      logger.debug("CMB: load for #{self.to_s}")
      # Pull the fields we need from the cached record into an options_hash
      options_hash = { :psar_file_and_symbol => @cached.psar_file_and_symbol }

      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = [ group_request ]

      # Setup Retain object
      retain_object = self.class.retain_class.new(options_hash)

      # Special case for psar.
      psar = retain_object.de32

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
      @cached.update_attributes(options)
    end
  end
end
