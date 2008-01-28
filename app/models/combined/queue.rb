module Combined
  class Queue < Base

    set_expire_time 30.minutes

    def to_s
      queue_name.sub(/ +/, '') + ',' + center + ',' + (h_or_s || 'S')
    end
    
    private

    def load
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")
      cached = self.cached
      
      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{  queue_name center h_or_s }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

      # :requested_elements is a special case
      requested_elements = Combined::Call.retain_fields.map { |field| field.to_sym }
      logger.debug("requested_elements = #{requested_elements.inspect}")
      options_hash[:requested_elements] = requested_elements

      # We need to clean out any cached calls.
      @calls_cache = nil
      logger.debug("###: cached is of type #{cached.class}")
      cached.calls.clear
      
      # Create a Retain::Queue from the options cache.
      retain_queue = Retain::Queue.new(options_hash)

      # Now we get our create the list of calls
      retain_queue.calls.each do |call|
        db_call = Cached::Call.new_from_retain(call)
        db_pmr = Cached::Pmr.new_from_retain(call)
        db_call.pmr = db_pmr
        cached.calls << db_call
      end
      cached.save
    end
  end
end
