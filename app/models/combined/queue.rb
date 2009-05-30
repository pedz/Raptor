module Combined
  class Queue < Base
    set_expire_time 5.minutes

    set_db_keys :queue_name, :h_or_s
    add_skipped_fields :queue_name, :h_or_s
    add_non_retain_associations :owners, :queue_infos, :favorite_queues
    set_db_constants :queue_name, :h_or_s, :center
      
    # Words is an array of string in the order of
    # queue_name,h_or_s,center
    def self.words_to_options(words)
      # logger.debug("words is of clas #{words.class}")
      # logger.debug("words is #{words.inspect}")
      options = { 
        :queue_name => words.shift,
        :h_or_s => words.shift
        }
      Combined::Center.words_to_options(words).merge(options)
    end

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
        return nil unless q.valid?(options.merge({ :center => words[2]}))
      end
      q
    end
    
    def to_id
      queue_name.strip + '_' + (h_or_s || 'S') + '_' + self.center.to_param
    end
    
    def to_param
      queue_name.strip + ',' + (h_or_s || 'S') + ',' + self.center.to_param
    end
    
    def to_options
      { :queue_name => queue_name, :h_or_s => h_or_s }.merge(center.to_options)
    end
    
    def valid?(options = to_options)
      Retain::Cq.valid?(options)
    end
    
    # format is not used here.
    def hits(format)
      begin
        Retain::Cq.new(to_options).hit_count
      rescue Retain::SdiReaderError => e
        raise e unless e.message[0,13] == "INVALID QUEUE"
        -1
      end
    end

    private

    def load
      # logger.debug("CMB: load for #{self.to_param}")
      # This could be generallized but for now lets just do this
      return if @cached.queue_name.nil?
      
      time_now = Time.now

      # Pull the fields we need from the cached record into an options_hash
      options_hash = {
        :queue_name => @cached.queue_name,
        :h_or_s => @cached.h_or_s,
        :center => @cached.center.center
      }

      # :requested_elements is a special case
      requested_elements = Combined::Call.retain_fields.map { |field| field.to_sym }
      requested_elements << :ppg
      requested_elements << :p_s_b
      # logger.debug("CMB: requested_elements = #{requested_elements.inspect}")
      options_hash[:requested_elements] = requested_elements

      
      # Create a Retain::Queue from the options cache.
      retain_queue = Retain::Queue.new(options_hash)
      retain_calls = retain_queue.calls

      # I'm going to try this...
      db_calls = @cached.calls
      # db_calls.each_with_index do |o, i|
      #   hex = ""
      #   if o.call_search_result
      #     o.call_search_result.each_byte { |b| hex << ("%02x" % b) }
      #   end
      #   logger.debug("db_calls[#{i}] is #{hex}")
      # end
      # retain_calls.each_with_index do |o, i|
      #   hex = ""
      #   if o.call_search_result
      #     o.call_search_result.each_byte { |b| hex << ("%02x" % b) }
      #   end
      #   logger.debug("retain_calls[#{i}] is #{hex}")
      # end

      # If retain says we have no calls, we delete the calls in the
      # database.
      if retain_calls.length == 0
        # logger.debug("CMB: Queue is empty")
        # If DB already says there are no calls, we skip this.
        unless db_calls.length == 0
          @cached.calls.clear
          @cached.last_fetched = time_now
        end
        @cached.dirty = false
        @cached.updated_at = time_now
        @cached.save
        return
      end

      # We run through to see if nothing has changed.  We do this by
      # checking if the sequence of call_search_results are the same
      # for the list of calls just returned by retain and those saved
      # in the database.
      if retain_calls.length == db_calls.length &&
          (0 ... retain_calls.length).all? { |index|
          retain_calls[index].call_search_result === db_calls[index].call_search_result
        }
        # logger.debug("CMB: Queue appears to have not changed")
        @cached.dirty = false
        @cached.updated_at = time_now
        @cached.save
        return
      end

      # Note, at this point, we know that the queue has changed.  So,
      # unlike most combined models, at the end of the routine (below)
      # we will always set last_fetched.  The @queue.changed? is not
      # valid because no attributes have changed -- only the
      # associations.

      # I'm going to make this a separate pass from above... it seems
      # easier and doesn't cost too much
      db_calls_hash = { }
      db_calls.each_index { |index| db_calls_hash[db_calls[index].call_search_result] = index }
      db_call_index = 0
      # We run through the indexes for the list of calls returned by
      # Retain.  This loop will delete the calls in the database that
      # are no longer valid.
      (0 ... retain_calls.length).each do |index|
        retain_call = retain_calls[index]
        db_call = db_calls[db_call_index]
        # logger.debug("CMB: Queue at index #{index}")

        # If match at the current index, just move the db call to the
        # list and continue
        if !db_call.nil? && (retain_call.call_search_result === db_call.call_search_result)
          # logger.debug("CMB: index #{index} db_call_index #{db_call_index} matches")
          db_call_index += 1
          next
        end

        # If the call is in the list of db_calls, then we must have
        # deleted from the queue so we need to delete from db_calls
        # until we match
        if db_calls_hash.has_key?(retain_call.call_search_result)
          while (retain_call.call_search_result != db_call.call_search_result) &&
              (db_call_index < db_calls.length)
            # logger.debug("CMB: delete db_call_index #{db_call_index}")
            db_calls.delete(db_call)
            db_call = db_calls[db_call_index]
          end
          db_call_index += 1
          next
        end
        
        # retain_call not in db_calls so insert it.
        # logger.debug("CMB: new retain_call #{index}")
      end

      # Need to delete the db_calls left at the end if any
      while db_call_index < db_calls.length
        # logger.debug("CMB: delete db_call at index #{db_call_index}")
        db_call = db_calls[db_call_index]
        db_calls.delete(db_call)
      end

      # Now we get our create the list of calls
      slot = 1
      retain_calls.each do |call|
        # The call only has the bare essentials.
        group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
        call.group_requests = group_request

        # This will touch an unset field and cause a fetch.
        pmr_options = {
          :problem => call.problem,
          :branch  => call.branch,
          :country => call.country
        }
        call_options = Cached::Call.options_from_retain(call)
        db_call = @cached.calls.find_or_new(call_options)
        unless db_call.new_record?
          db_call.attributes = call_options
        end
        if db_call.changed?
          db_call.last_fetched = time_now
        end
        db_call.slot = slot
        db_call.dirty = false
        slot += 1
        
        # If/when we start keeping expired PMRs we need to augment
        # this call to not find expired PMRs.  We do not have the
        # create date at this point but if we exclude expired PMRs,
        # then we will create a new PMR if we hit the case of a
        # duplicate problem,branch,country.

        # Make or find PMR
        db_pmr = Cached::Pmr.find_or_new(pmr_options)

        # This code is duplicated three times presently.  The problem
        # is that we do not want the center or other fields from the
        # call to enter in to the search or values for the customer.
        # So, we do a specific search for the customer by country and
        # customer number.
        #
        # Well, actually that is only half the problem.  The bigger
        # problem with the PMR and customer is that we do not want to
        # fetch them from Retain until we need something from them.
        # That is why we construct the database objects in multiple
        # places.
        cust_options = {
          :country => call.country,
          :customer_number => call.customer_number
        }
        db_customer = Cached::Customer.find_or_new(cust_options)
        db_pmr.customer = db_customer
        db_call.pmr = db_pmr

        # We just do the save which will cause updated_at to be
        # modified.  It also causes the PMR and customer to be saved
        # if they are new.
        db_call.updated_at = time_now
        db_call.save
      end
      # Force the reload of the calls.
      @cached.calls(true)

      @cached.dirty = false
      # Just to repeat the comment above: if we get to this point, we
      # know that the queue has changed.  We must change last_fetched.
      # Checking the last_fetched of the calls or the PMRs won't work
      # because a call might be deleted which would cause us to need
      # to update the page caches for the queue.
      @cached.last_fetched = time_now
      @cached.updated_at = time_now
      @cached.save
    end
  end
end
