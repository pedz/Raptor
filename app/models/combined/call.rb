module Combined
  class Call < Base
    add_skipped_fields :queue_id, :pmr_id, :ppg, :p_s_b
    add_extra_fields :problem, :branch, :country

    set_expire_time 30.minutes
    
    def self.from_param(param)
      words = param.split(',')
      ppg = words.pop
      queue = Combined::Queue.from_param(words.join(','))
      queue.calls.find_or_initialize_by_ppg(ppg)
    end

    def to_param
      queue.to_param + ',' + ppg
    end
    
    def load
      logger.debug("CMB: load for <#{self.class.to_s}:#{"0x%x" % self.object_id}>")
      cached = self.cached

      # Pull the fields we need from the cached record into an options_hash
      queue = cached.queue
      options_hash = Hash[ *%w{  queue_name center h_or_s }.map { |field|
                             [ field.to_sym, queue.attributes[field] ] }.flatten ]
      options_hash[:ppg] = cached.ppg
      logger.debug("CMB: options_hash = #{options_hash.inspect}")

      # :group_request is a special case
      group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
      logger.debug("CMB: group_request = #{group_request.inspect}")
      options_hash[:group_request] = group_request

      call = Retain::Call.new(options_hash)

      # Touch something
      call.priority
      call_options = Cached::Call.options_from_retain(call)
      cached.pmr = Cached::Pmr.new_from_retain(call)
      cached.update_attributes(call_options)
    end
  end
end
