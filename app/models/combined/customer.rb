module Combined
  class Customer < Base
    set_expire_time :never

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
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")

      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{  country customer_number }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

      # :group_request is a special case
      group_request = Combined::Customer.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = group_request

      # Setup Retain Customer object
      retain_customer = Retain::Customer.new(options_hash)

      # Touch to cause a fetch
      retain_customer.company_name

      # Retrieve good stuff
      cache_options = Cached::Customer.options_from_retain(retain_customer)
      @cached.update_attributes(cache_options)
    end
  end
end
