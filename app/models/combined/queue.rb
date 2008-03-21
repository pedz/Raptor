module Combined
  class Queue < Base
    set_expire_time 30.minutes

    set_db_keys :queue_name, :h_or_s
    add_skipped_fields :queue_name, :h_or_s

    set_db_constants :queue_name, :h_or_s, :center

    # Param is queue_name,h_or_s,center.  Raises QueueNotFound if
    # queue is not in database or Retain.
    def self.from_param!(param)
      q = from_param(param)
      if q.nil?
        raise QueueNotFound.new(param)
      end
      q
    end

    # Param is queue_name,h_or_s,center
    def self.from_param(param)
      words = param.upcase.split(',')
      center = Combined::Center.from_param(words[2])
      return nil if center.nil?
      
      options = {
        :queue_name => words[0].strip,
        :h_or_s => words[1]
      }
      q = find(:first, :conditions => options)
      if q.nil?
        q = center.queues.build(options)
        return nil unless q.valid?
      end
      q
    end
    
    def to_param
      queue_name.strip + ',' + (h_or_s || 'S') + ',' + center.to_param
    end
    
    def to_options
      { :queue_name => queue_name, :h_or_s => h_or_s }.merge(center.to_options)
    end
    
    def valid?
      Retain::Cq.valid?(to_options)
    end
    
    def hits
      Retain::Cq.new(to_options).hit_count
    end

    private

    def load
      logger.debug("CMB: load for #{self.to_s}")
      cached = self.cached
      
      # This could be generallized but for now lets just do this
      return if cached.queue_name.nil?
      
      # Pull the fields we need from the cached record into an options_hash
      options_hash = {
        :queue_name => cached.queue_name,
        :h_or_s => cached.h_or_s,
        :center => cached.center.center
      }

      # :requested_elements is a special case
      requested_elements = Combined::Call.retain_fields.map { |field| field.to_sym }
      requested_elements << :ppg
      requested_elements << :p_s_b
      logger.debug("CMB: requested_elements = #{requested_elements.inspect}")
      options_hash[:requested_elements] = requested_elements

      # We need to clean out any cached calls.
      @calls_cache = nil
      logger.debug("CMB: cached is of type #{cached.class}")
      cached.calls.clear
      
      # Create a Retain::Queue from the options cache.
      retain_queue = Retain::Queue.new(options_hash)

      # We have to keep track of the new customers we create so we do
      # not try and create duplicates.  The same is true for PMRs
      # since a queue can have secondaries of the same PMR.
      new_customers = { }
      new_pmrs = { }
      
      # Now we get our create the list of calls
      retain_queue.calls.each do |call|
        # The call only has the bare essentials.  This will touch the
        # call and cause a fetch.  So when the db record is created,
        # it will be more complete.
        group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
        call.group_requests = group_request
        pmr_options = {
          :problem => call.problem,
          :branch  => call.branch,
          :country => call.country
        }
        db_call = cached.calls.new_from_retain(call)
        logger.debug("here #{__LINE__}")
        
        # If/when we start keeping expired PMRs we need to augment
        # this call to not find expired PMRs.  We do not have the
        # create date at this point but if we exclude expired PMRs,
        # then we will create a new PMR if we hit the case of a
        # duplicate problem,branch,country.

        # Make or find PMR
        pmr_key = call.problem + call.branch + call.country
        if new_pmrs.has_key?(pmr_key)
          db_pmr = new_pmrs[pmr_key]
        else
          db_pmr = Cached::Pmr.find_or_new(pmr_options)
          if db_pmr.new_record?
            new_pmrs[pmr_key] = db_pmr
          end
        end
        logger.debug("here #{__LINE__}")

        # This code is duplicated three times presently.  The problem
        # is that we do not want the center or other fields from the
        # call to enter in to the search or values for the customer.
        # So, we do a specific search for the customer by country and
        # customer number.
        cust_options = {
          :country => call.country,
          :customer_number => call.customer_number
        }
        logger.debug("here #{__LINE__}")
        cust_key = call.country + call.customer_number
        if new_customers.has_key?(cust_key)
          db_customer = new_customers[cust_key]
        else
          db_customer = Cached::Customer.find_or_new(cust_options)
          if db_customer.new_record?
            new_customers[cust_key] = db_customer
          end
        end
        logger.debug("here #{__LINE__}")
        db_pmr.customer = db_customer
        logger.debug("here #{__LINE__}")
        db_call.pmr = db_pmr
        logger.debug("here #{__LINE__}")
        cached.calls << db_call
        logger.debug("here #{__LINE__}")
      end
      logger.debug("here #{__LINE__}")
      cached.save
    end
  end
end
