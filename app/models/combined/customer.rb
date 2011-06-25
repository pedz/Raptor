# -*- coding: utf-8 -*-

module Combined
  class Customer < Base
    set_expire_time 3.days
    set_db_keys :country, :customer_number
    add_skipped_fields :country, :customer_number, :pat
    
    set_db_constants :country, :customer_number, :center

    add_skipped_fields :center_id
    add_extra_fields   :center

    def to_param
      @cached.country + @cached.customer_number
    end

    # signon_user is not used.
    def self.from_param(param, signon_user = nil)
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
    
    # Customer Time Zone as a rational fraction of a day
    def tz
      # logger.debug("CHC: customer tz called from #{caller.join("\n")}")
      if tzb = to_combined.time_zone_binary
        tzb.to_r / MINS_PER_DAY
      else
        nil
      end
    end
    once :tz

    private
    
    def load
      # logger.debug("CMB: load for #{self.to_param}")
      
      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{  country customer_number }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]
      
      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = [ group_request ]
      
      # Setup Retain object
      retain_object = self.class.retain_class.new(retain_user_connection_parameters, options_hash)
      
      # Touch to cause a fetch
      begin
        retain_object.send(group_request[0])
      rescue Retain::SdiReaderError => err
        raise err unless err.rc == 251
        # logger.debug("CMB: load customer caught an exception")
        options = { }
      else
        # Hook up center
        unless (c = retain_object.center).blank?
          @cached.center = Cached::Center.find_or_new(:center => c)
        end
        
        # Update call record
        options = self.class.cached_class.options_from_retain(retain_object)
        # logger.debug("CMB: load customer options = #{options.inspect}")
      end
      options[:dirty] = false if @cached.respond_to?("dirty")
      @cached.updated_at = Time.now
      @cached.update_attributes(options)
    end
  end
end
