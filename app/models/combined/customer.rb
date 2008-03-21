module Combined
  class Customer < Base
    set_expire_time 30.minutes
    set_db_keys :country, :customer_number
    add_skipped_fields :country, :customer_number
    
    set_db_constants :country, :customer_number, :center

    add_skipped_fields :center_id
    add_extra_fields   :center

    def to_param
      @cached.country + @cached.customer_number
    end

    def self.from_param(param)
      case param.length
      when 7
        country = '000'
        cnum = param
      when 10
        country = param[0 .. 2]
        cnum = param[3 .. 9]
      else
        raise "param for customer not understood: #{param}"
      end
      find_or_initialize_by_country_and_customer_number(country, cnum)
    end

    private
    
    def load
      logger.debug("CMB: load for #{self.to_s}")

      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{  country customer_number }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = group_request

      # Setup Retain object
      retain_object = self.class.retain_class.new(options_hash)

      # Touch to cause a fetch
      retain_object.send(group_request[0])

      # Hook up center
      unless (c = retain_object.center).blank?
        @cached.center = Cached::Center.find_or_new(:center => c)
      end

      # Retrieve good stuff
      cache_options = self.class.cached_class.options_from_retain(retain_object)
      @cached.update_attributes(cache_options)
    end
  end
end
