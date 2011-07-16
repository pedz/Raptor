# -*- coding: utf-8 -*-

module Combined
  # === Combined Customer Model
  class Customer < Base
    ##
    # :attr: expire_time
    # set to 3.days
    set_expire_time 3.days

    set_db_keys :country, :customer_number
    add_skipped_fields :country, :customer_number, :pat
    
    set_db_constants :country, :customer_number, :center

    add_skipped_fields :center_id
    add_extra_fields   :center

    ##
    # A param for a customer is the country with the customer_number
    # appended to it (no space or comma).
    def to_param
      @cached.country + @cached.customer_number
    end

    ##
    # signon_user is not used.  Tries to accept various forms.  If
    # param is 7 letters, then a county of 000 is assumed.  Otherwise,
    # if param is not 10 letters, an exception is raised.  Returns a
    # Customer based upon the param passed in.
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

    ##
    # Given a start time, adds the specified number of business days
    # to the time according to the rules for the Customer (their
    # timezone) and returns that time.
    def business_days(start_time, days)
      jims_business_days(start_time, days)
    end

    ##
    # Given a start time, adds the specified number of business hours
    # to the time according to the rules for the Customer and returns
    # that time.
    def business_hours(start_time, hours)
      jims_business_hours(start_time, hours)
    end

    JIM = Array.new(3 * 24 * 7, 0)
    
    (0 .. 2).each { |week|
      (1 .. 5).each { |day|
        (8 .. 16).each { |hour|
          JIM[(week * 7 + day) * 24 + hour] = 1
        }
      }
    }

    ##
    # Called from business_days.  Jim's algorithm proved the most
    # stable.
    def jims_business_days(start_time, days)
      local_tz = tz || 0
      cust_time = cust_start_time = start_time.new_offset(local_tz)
      i1 = start_i1 = (cust_time.wday * 24 + cust_time.hour)
      stomp_on_mins = false
      until JIM[i1] == 1
        i1 += 1
        stomp_on_mins = true
      end
      until days == 0
        i1 += 24
        days -= JIM[i1]
      end
      if stomp_on_mins
        start_time -= start_time.min.minutes
      end
      start_time + (i1 - start_i1).hours
    end

    ##
    # Called from business_hours.
    def jims_business_hours(start_time, hours)
      local_tz = tz || 0
      cust_time = start_time.new_offset(local_tz)
      i1 = start_i1 = (cust_time.wday * 24 + cust_time.hour)
      stomp_on_mins = false
      until JIM[i1] == 1
        i1 += 1
        stomp_on_mins = true
      end
      until hours == 0
        i1 += 1
        hours -= JIM[i1]
      end
      if stomp_on_mins
        start_time -= start_time.min.minutes
      end
      start_time + (i1 - start_i1).hours
    end

    private

    ##
    # Load (fetch) the Customer record from Retain and save it into
    # the database.
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
