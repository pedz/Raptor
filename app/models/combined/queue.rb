# -*- coding: utf-8 -*-

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
    def self.from_param!(param, signon_user = nil)
      q = from_param(param, signon_user)
      if q.nil?
        raise QueueNotFound.new(param)
      end
      q
    end

    # Param is queue_name,h_or_s,center
    def self.from_param(param, signon_user = nil)
      words = param.upcase.split(',')
      case words.length
        # default to user's personal queue
      when 0
        logger.info("when 0")
        return signon_user.personal_queue
        
        # assume the single word is the queue
        # name and get the center and h_or_s from the registration
      when 1
        logger.info("when 1")
        options = {
          :queue_name => words[0],
          :h_or_s => signon_user.default_h_or_s,
        }
        center = signon_user.default_center

        # assume queue_name and center (since few people know / care
        # about h_or_s.  So, get h_or_s from registration
      when 2
        logger.info("when 2")
        options = {
          :queue_name => words[0],
          :h_or_s => signon_user.default_h_or_s,
        }
        center = Combined::Center.from_param(words[1], signon_user)
        
      else
        logger.info("when 3: #{words[2]}")
        options = {
          :queue_name => words[0],
          :h_or_s => words[1],
        }
        center = Combined::Center.from_param(words[2], signon_user)
        logger.info("center is #{center.center}")
      end
      return nil if center.nil?

      q = center.queues.find(:first, :conditions => options)
      if q.nil?
        q = center.queues.build(options)
        return nil unless q.queue_valid?
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
    
    # This was called just valid? but it confused me with the class
    # methods valid?
    def queue_valid?(options = to_options)
      Retain::Cq.valid?(@params, options)
    end
    
    # format is not used here.
    def hits(format)
      begin
        Retain::Cq.new(@params, to_options).hit_count
      rescue Retain::SdiReaderError => e
        raise e unless e.message[0,13] == "INVALID QUEUE"
        -1
      end
    end

    private

    def load
      # This could be generallized but for now lets just do this
      return if @cached.queue_name.nil?

      # logger.debug("CMB: load for #{self.to_param}")
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
      retain_queue = Retain::Queue.new(@params, options_hash)
      retain_calls = retain_queue.calls

      # We know that the queue is valid or the calls method above
      # would have raised an expcetion.  We are going to attach calls
      # to this queue and that does not work with a new record so we
      # go ahead and save it to the database.
      @cached.save if @cached.new_record?

      # retain_calls are the calls from retain while db_calls are the
      # calls that the database knows about.
      db_calls = @cached.calls

      # If retain says we have no calls, we delete the calls in the
      # database and go home.
      if retain_calls.length == 0
        # logger.debug("CMB: Queue is empty")

        # If DB already says there are no calls, then there are no
        # calls to delete and, also, we do not need to touch
        # last_fetched.
        unless db_calls.length == 0
          @cached.calls.clear
          @cached.last_fetched = time_now
        end

        # We know that the queue is not dirty, set the updated_at
        # time, and save what has changed.
        @cached.dirty = false
        @cached.updated_at = time_now
        @cached.save
        return
      end

      # A new approach: Mark all the db calls as not used.  Then walk
      # the retain call list.  If the ppg and call_search_result both
      # equal, then we assume its the same call (I can't see how it
      # could not be) and mark it as used.  Afterwards, we walk the db
      # call list and delete the unused calls.
      db_calls_hash = { }
      db_calls.each { |db_call|
        db_calls_hash[db_call.ppg] = db_call
        db_call.used = false
      }

      no_new = true
      slot = 0
      group_request = nil

      retain_calls.each do |retain_call|
        slot += 1
        db_call = db_calls_hash[retain_call.ppg]

        # Trust old call as the same
        if db_call && db_call.call_search_result == retain_call.call_search_result
          db_call.used = true
          db_call.slot = slot
          next
        end

        # first time through set these up
        if no_new
          no_new = false        # at least one new call
          group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
          group_request.freeze
        end

        # Make call fetch the fields we need
        retain_call.group_requests = group_request

        # This will touch an unset field and cause a fetch.
        pmr_options = {
          :problem => retain_call.problem,
          :branch  => retain_call.branch,
          :country => retain_call.country
        }

        # create or find the call
        call_options = Cached::Call.options_from_retain(retain_call)

        # If we have a call with the same ppg, we reuse it else we
        # find or create a new one.  I don't see how the find could
        # not return a new record in the case that db_call was
        # originally null.
        db_call = @cached.calls.find_or_new(call_options) unless db_call

        # if an old record, update it with new info
        unless db_call.new_record?
          db_call.attributes = call_options
        end

        db_call.used = true
        db_call.last_fetched = time_now if db_call.changed?
        db_call.slot = slot
        db_call.dirty = false

        # If/when we start keeping expired PMRs we need to augment
        # this call to not find expired PMRs.  We do not have the
        # create date at this point but if we exclude expired PMRs,
        # then we will create a new PMR if we hit the case of a
        # duplicate problem,branch,country.

        # Make or find PMR
        db_pmr = Cached::Pmr.find_or_new(pmr_options)

        # I believe now that customer is not required for pmrs, we can 
        # delete this code... To Be Done
        #
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
          :country => retain_call.country,
          :customer_number => retain_call.customer_number
        }
        db_customer = Cached::Customer.find_or_new(cust_options)
        db_customer.save
        db_pmr.customer = db_customer
        db_pmr.save
        db_call.pmr = db_pmr

        # We just do the save which will cause updated_at to be
        # modified.  It also causes the PMR and customer to be saved
        # if they are new.
        db_call.updated_at = time_now
        db_call.save
      end

      # delete any unused db_calls
      no_deletes = true
      db_calls.each do |db_call|
        unless db_call.used
          db_call.destroy
          no_deletes = false
        end
      end

      # mark as last_fetched if anything changed including adding or
      # deleting db calls.
      unless no_deletes && no_new && !@cached.changed?
        @cached.last_fetched = time_now
      end

      # Force the reload of the calls if we added or deleted db calls
      unless no_deletes && no_new
        @cached.calls(true)
      end
      @cached.dirty = false
      @cached.updated_at = time_now
      @cached.save
    end
  end
end
