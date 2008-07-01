module Combined
  class Call < Base
    set_expire_time 30.minutes

    set_db_keys :ppg
    add_skipped_fields :ppg
    add_skipped_fields :slot    # pure db field
    # This field comes from Retain in the PMCS call (fetch the queue)
    # and is used to see if the calls on the queue have changed.  But,
    # when we get the call itself, we don't want to fetch this field
    # (because we can't)
    add_skipped_fields :call_search_result

    set_db_constants :ppg, :queue, :pmr

    add_skipped_fields :queue_id, :pmr_id, :p_s_b
    add_extra_fields :problem, :branch, :country, :customer_number
    
    # words is an array of strings in the order of
    # queue_name,h_or_s,center,ppg
    def self.words_to_options(words)
      ppg = words.pop
      Combined::Queue.words_to_options(words).merge :ppg => ppg
    end
    
    def self.from_words(words)
      options = words_to_optins(words)
      if queue = Combined::Queue.from_options(options)
        call = queue.calls.find_or_initialize_by_ppg(options[:ppg])
     end
    end

    # Params must include 
    def self.from_param_pair!(param)
      words = param.split(',')
      ppg = words.pop
      queue = Combined::Queue.from_param!(words.join(','))
      [ queue.calls.find_or_initialize_by_ppg(ppg), queue ]
    end
    
    def self.from_param!(param)
      call, queue = from_param_pair!(param)
      call
    end

    def to_id
      queue.to_id + '_' + ppg
    end
    
    def to_param
      queue.to_param + ',' + ppg
    end

    def to_options
      { :ppg => ppg }.merge(queue.to_options)
    end

    # The validate_xxx methods problem need a name change.  They
    # return a three element array of a class name, help string, and a
    # boolean if the field is editable.
    def validate_owner(user)
      queue = self.queue
      user_center = user.center(queue.h_or_s)
      if user_center.center != queue.center.center
        return [ "normal", "Queue outside center not editable or judged", false]
      end

      # Lets deal with backups and secondarys.  As far as I know, they
      # are not editable for any reason.
      p_s_b = self.p_s_b
      if p_s_b == 'S' || p_s_b == 'B'
        return ["normal", "Owner for secondary/backup not editable or judged", false ]
      end

      pmr = self.pmr
      # World Trade, owner is always o.k.
      # TODO Actually, this isn't true.  It resolver or next queue get
      # clobbered they are not o.k.  We might could add code to detect that.
      if pmr.country != "000"
        return ["normal", "Owner for WT not editable or judged", false ]
      end

      pmr_owner = pmr.owner
      # A blank owner is a bad dog.
      if pmr_owner.signon.blank?
        return [ "wag-wag", "Owner should not be blank", true ]
      end

      # If Queue Owner is the same as PMR Owner, we're good.
      if (infos = queue.queue_infos).empty?
        return [ "warn", "Queue has no owner", true ]
      else
        queue_owner = infos[0].owner
        if pmr_owner.id == queue_owner.id
          return [ "good", "PMR Owner is Queue Owner", true ]
        end
      end

      owner_center = queue_owner.center(queue.h_or_s)
      if owner_center && owner_center.center == queue.center.center
        return [ "warn", "PMR Owner in same center but not queue owner", true ]
      end

      return [ "wag-wag", "PMR Owner not in same center", true ]
    end

    def validate_resolver(user)
      queue = self.queue
      user_center = user.center(queue.h_or_s)
      if user_center.center != queue.center.center
        return [ "normal", "Queue outside center not editable or judged", false]
      end

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
      if (infos = queue.queue_infos).empty?
        # If Queue has no owner, not much else we can do.
        return [ "warn", "Queue has no owner", true ]
      else
        queue_owner = infos[0].owner
        if pmr_resolver.id == queue_owner.id
          return [ "good", "PMR Resolver is Queue Owner", true ]
        end
      end

      resolver_center = pmr_resolver.center(queue.h_or_s)
      if resolver_center && resolver_center.center == queue.center.center
        return [ "warn", "PMR Resolver in same center but not queue owner", true ]
      end

      return [ "wag-wag", "PMR Resolver not in same center", true ]
    end

    def validate_next_queue(user)
      queue = self.queue
      user_center = user.center(queue.h_or_s)
      if user_center.center != queue.center.center
        return [ "normal", "Queue outside center not editable or judged", false]
      end

      # Lets deal with backups and secondarys.  As far as I know, they
      # are not editable for any reason.
      p_s_b = self.p_s_b
      if p_s_b == 'S' || p_s_b == 'B'
        return ["normal", "Next Queue for secondary/backup not editable or judged", false ]
      end
      
      pmr = self.pmr
      # World Trade, next queue is always o.k.
      # TODO Actually, this isn't true.  It resolver or next queue get
      # clobbered they are not o.k.  We might could add code to detect that.
      if pmr.country != "000"
        return ["normal", "Next Queue for WT not editable or judged", false ]
      end

      if pmr.next_center.nil?
        return [ "wag-wag", "Next Queue center is invalid", true ]
      end

      next_queue = pmr.next_queue
      if next_queue.nil?
        return [ "wag-wag", "Next Queue queue name is invalid", true ]
      end

      # We are going to assume that if we have no queue info records
      # on this queue, then it is a team queue.
      if (infos = queue.queue_infos).empty?
        return [ "good", "Team queues are not editable or judged", false ]
      end

      # Personal queue set to next queue... bad dog.
      if next_queue.id == queue.id
        return [ "wag-wag", "Next queue set to personal queue", true ]
      end

      unless next_queue.queue_infos.empty?
        return [ "warn", "Next queue is a personal queue", true ]
      end

      return [ "good", "I can not find anything to complain about", true ]
    end
    
    private
    
    def load
      logger.debug("CMB: load for #{self.to_s}")
      # debugger()

      # Pull the fields we need from the cached record into an options_hash
      queue = @cached.queue
      options_hash = {
        :queue_name => queue.queue_name,
        :h_or_s => queue.h_or_s,
        :center => queue.center.center,
        :ppg => @cached.ppg
      }
      logger.debug("CMB: options_hash = #{options_hash.inspect}")

      # :group_request is a special case
      group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
      logger.debug("CMB: group_request = #{group_request.inspect}")
      options_hash[:group_request] = [ group_request ]

      # Create retain object
      call = Retain::Call.new(options_hash)

      # Touch to force a fetch from Retain
      call.send(group_request[0])

      # Make or find PMR
      pmr_options = {
        :problem => call.problem,
        :branch  => call.branch,
        :country => call.country
      }
      @cached.pmr = Cached::Pmr.find_or_new(pmr_options)

      # Make or find customer
      cust_options = {
        :country => call.country,
        :customer_number => call.customer_number
      }
      @cached.pmr.customer = Cached::Customer.find_or_new(cust_options)

      # Update call record
      options = self.class.cached_class.options_from_retain(call)
      options[:dirty] = false if @cached.respond_to?("dirty")
      @cached.update_attributes(options)
    end
  end
end
