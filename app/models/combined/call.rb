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

    # The validate_xxx methods problem need a name change.  They
    # return a three element array of a class name, help string, and a
    # boolean if the field is editable.
    def validate_owner
      # Lets deal with backups and secondarys.  As far as I know, they
      # are not editable for any reason.
      p_s_b = self.p_s_b
      if p_s_b == 'S' || p_s_b == 'B'
        return ["normal", "Owner for secondary/backup not editable or judged", false ]
      end

      pmr = self.pmr
      # World Trade, owner is always o.k.
      if pmr.country != "000"
        return ["normal", "Owner for WT not editable or judged", false ]
      end

      pmr_owner = pmr.owner
      # A blank owner is a bad dog.
      if pmr_owner.signon.blank?
        return [ "wag-wag", "Owner should not be blank", true ]
      end

      # If Queue Owner is the same as PMR Owner, we're good.
      queue = self.queue
      if (infos = queue.queue_infos).empty?
        return [ "warn", "Queue has no owner", true ]
      else
        queue_owner = infos[0].owner
        if pmr_owner.id == queue_owner.id
          return [ "good", "PMR Owner is Queue Owner", true ]
        end
      end

      center = queue_owner.center(queue.h_or_s)
      if center && center == queue.center
        return [ "warn", "PMR Owner in same center but not queue owner", true ]
      end

      return [ "wag-wag", "PMR Owner not in same center", true ]
    end

    def validate_resolver
      # Lets deal with backups and secondarys.  As far as I know, they
      # are not editable for any reason.
      p_s_b = self.p_s_b
      if p_s_b == 'S' || p_s_b == 'B'
        return ["normal", "Resolver for secondary/backup not editable or judged", false ]
      end

      pmr = self.pmr
      pmr_resolver = pmr.resolver
      # A blank resolver is a bad dog.
      if pmr_resolver.signon.blank?
        return [ "wag-wag", "Resolver should not be blank", true ]
      end

      # If Queue Resolver is the same as PMR Resolver, we're good.
      queue = self.queue
      if (infos = queue.queue_infos).empty?
        # If Queue has no owner, not much else we can do.
        return [ "warn", "Queue has no owner", true ]
      else
        queue_owner = infos[0].owner
        if pmr_resolver.id == queue_owner.id
          return [ "good", "PMR Resolver is Queue Owner", true ]
        end
      end

      center = queue_owner.center(queue.h_or_s)
      if center && center == queue.center
        return [ "warn", "PMR Resolver in same center but not queue owner", true ]
      end

      return [ "wag-wag", "PMR Resolver not in same center", true ]
    end
    
    private
    
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
