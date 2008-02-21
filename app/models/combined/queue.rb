module Combined
  class Queue < Base

    set_expire_time 30.minutes

    def self.from_param(param)
      registration = Combined::Registration.default_user
      options = { 
        :center => registration.default_center,
        :h_or_s => registration.default_h_or_s
      }
      words = param.split(',')
      options[:queue_name] = words[0].upcase.strip
      options[:center] = words[1].upcase if words.length > 1
      options[:h_or_s] = words[2].upcase if words.length > 2
      q = Combined::Queue.find(:first, :conditions => options)

      # Create the queue if we need to but only if it is valid.
      if q.nil? && Retain::Cq.check_queue(options)
        q = Combined::Queue.new(options)
      end
      q
    end

    def to_param
      queue_name.strip + ',' + center + ',' + (h_or_s || 'S')
    end
    
    private

    def load
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")
      cached = self.cached
      
      # This could be generallized but for now lets just do this
      return if cached.queue_name.nil?
      
      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{  queue_name center h_or_s }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

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
        db_pmr = Cached::Pmr.new_from_retain(call)
        db_call.pmr = db_pmr
        cached.calls << db_call
      end
      cached.save
    end
  end
end