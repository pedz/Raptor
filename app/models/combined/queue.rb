module Combined
  class Queue < Base

    set_expire_time 30.minutes

    def self.from_param(param, fetch_user = nil)
      words = param.split(',')
      if words.length < 3 && fetch_user
        registration = fetch_user.call
      end
      if words.length > 2
        center = Combined::Center.from_param(words[2].upcase)
      else
        center = registration.default_center
      end
      options = {
        :queue_name => words[0].upcase.strip,
        :h_or_s => words.length > 1 ? words[1].upcase : registration.default_h_or_s
      }
      q = center.queues.find(:first, :conditions => options)

      # Create the queue if we need to but only if it is valid.
      if q.nil?
        center_options = { :center => center.to_param }
        if Retain::Cq.check_queue(center_options.merge(options))
          q = center.queues.build(options)
        else
          raise QueueNotFound.new(param)
        end
      end
      q
    end

    def to_param
      queue_name.strip + ',' + (h_or_s || 'S') + ',' + center.to_param
    end
    
    private

    def load
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")
      cached = self.cached
      
      # This could be generallized but for now lets just do this
      return if cached.queue_name.nil?
      
      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{  queue_name h_or_s }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]
      options_hash[:center] = cached.center.center

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

      # Now we get our create the list of calls
      retain_queue.calls.each do |call|
        db_call = Cached::Call.new_from_retain(call)
        # If/when we start keeping expired PMRs we need to augment
        # this call to not find expired PMRs.  We do not have the
        # create date at this point but if we exclude expired PMRs,
        # then we will create a new PMR if we hit the case of a
        # duplicate problem,branch,country.

        # Make or find PMR
        pmr_options = {
          :problem => call.problem,
          :branch  => call.branch,
          :country => call.country
        }
        db_pmr = Cached::Pmr.find_or_new(pmr_options)

        # This code is duplicated three times presently.  The problem
        # is that we do not want the center or other fields from the
        # call to enter in to the search or values for the customer.
        # So, we do a specific search for the customer by country and
        # customer number.
        cust_options = {
          :country => call.country,
          :customer_number => call.customer_number
        }
        db_pmr.customer = Cached::Customer.find_or_new(cust_options)
        
        db_call.pmr = db_pmr
        cached.calls << db_call
      end
      cached.save
    end
  end
end
