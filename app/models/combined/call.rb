module Combined
  class Call < Base
    add_skipped_fields :queue_id, :pmr_id, :ppg, :p_s_b
    add_extra_fields :problem, :branch, :country

    set_expire_time 30.minutes
    
    #
    # The to_s is called for named routes
    #
    def to_s
      queue.to_s + ',' + ppg
    end
    
    def load
      logger.debug("CMD: load for <#{self.class.to_s}:#{"0x%x" % self.object_id}>")
      cached = self.cached

      # Pull the fields we need from the cached record into an options_hash
      queue = cached.queue
      options_hash = Hash[ *%w{  queue_name center h_or_s }.map { |field|
                             [ field.to_sym, queue.attributes[field] ] }.flatten ]
      options_hash[:ppg] = cached.ppg
      logger.debug("options_hash = #{options_hash.inspect}")

      # :group_request is a special case
      group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
      logger.debug("group_request = #{group_request.inspect}")
      options_hash[:group_request] = group_request

      call = Retain::Call.new(options_hash)

      # Touch something
      call.priority
      call_options = Cached::Call.options_from_retain(call)
      cached.pmr = Cached::Pmr.new_from_retain(call) if cached.pmr.nil?
      cached.update_attributes(call_options)
    end
  end
end
