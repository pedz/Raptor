# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# === Combined Models
#
# These models represent the combined models.  See Combined::Base for
# more information.
#
# Each Retain concept such as Pmr, Call, Queue has a matchiing
# Combined model which wraps the matching Retain and Cached models to
# provide for a consistent and convenient interface.
#
# Here is an example.  If we create a Combined::Call with
#
#     c = Combined::Call.find(:first)
#
# notice that we do a database find which searchs the Cached::Call
# models and picks the first one -- standard ActiveRecord::Base find.
# When we access a particular field like
#
#     j = c.ppg
#
# it will check the updated_at time and the dirty flag to determine if
# a new copy needs to be fetched from Retain.  If it does, a
# Retain::Call will be created, the fetch from Retain is done, and the
# results pumped back into the cached model and thus saved into the
# database.  j will then get assigned the fresh updated value of ppg.
#
# The criterial to determine if the value in the database is current
# is done by Combined::Base.cache_valid?
#
module Combined
  # === Combined Call model
  class Call < Combined::Base
    set_db_keys :ppg
    add_skipped_fields :slot    # pure db field

    # This field comes from Retain in the PMCS call (fetch the queue)
    # and is used to see if the calls on the queue have changed.  But,
    # when we get the call itself, we don't want to fetch this field
    # (because we can't)
    add_skipped_fields :call_search_result

    # Many items in a call is a constant since they reflect back to
    # the 'name' of the call.  e.g. the priority is part of the ppg.
    set_db_constants :ppg, :queue, :pmr, :priority

    add_skipped_fields :queue_id, :pmr_id, :p_s_b
    add_extra_fields :problem, :branch, :country, :customer_number
    
    # Skip all the new fields which we compute and cache when we fetch
    # the call
    add_skipped_fields :owner_css,      :owner_message,      :owner_editable
    add_skipped_fields :resolver_css,   :resolver_message,   :resolver_editable
    add_skipped_fields :next_queue_css, :next_queue_message, :next_queue_editable

    ##
    # Each Combined model should have a similar routine.  words is an
    # array of strings in the order of queue_name,h_or_s,center,ppg.
    # Returns a options hash with keys of :queue, :h_or_s, :center,
    # :ppg
    def self.words_to_options(words)
      ppg = words.pop
      ppg.downcase!
      Combined::Queue.words_to_options(words).merge(:ppg => ppg)
    end
    
    ##
    # Returns an array with the call as the first element and the
    # queue as the second.  Params must include four parts:
    # queue,S,center,ppg.  signon_user is passed in.  If param is a
    # single word, we default queue, s, and center to the
    # signon_user's personal queue if we can find it.  This work is
    # done when the queue is fetched.
    def self.from_param_pair!(param, signon_user = nil)
      words = param.split(',')
      raise CallNotFound.new(to_param) if words.empty?
      ppg = words.pop
      ppg.downcase!
      queue = Combined::Queue.from_param!(words.join(','), signon_user)
      # We did not raise an exception so queue must be valid
      c = queue.calls.find_or_initialize_by_ppg(ppg)
      if c.new_record?
        # fetch the comments.  If this is not a valid call, the load
        # will throw an exception
        comments = c.comments
      end
      [ c, queue ]
    end
    
    ##
    # Given a set of params, returns the call.
    def self.from_param!(param, signon_user = nil)
      call, queue = from_param_pair!(param, signon_user)
      call
    end

    ##
    # to_id is used in various Rails routines and usually returns the
    # database id.  It is overridden to return the
    # Combined::Queue#to_id followed by underscore and the ppg.
    def to_id
      queue.to_id + '_' + ppg
    end
    
    ##
    # Returns the params that could be used to retrieve this call.
    def to_param
      queue.to_param + ',' + ppg
    end

    ##
    # Returns a hash containing the needed entries to retrieve this
    # call.
    def to_options
      { :ppg => ppg }.merge(queue.to_options)
    end

    ##
    # The validate_xxx methods need a name change.  They return a hash
    # with entries for css_class, title, editable, name, and width.
    def validate_owner(user)
      if owner_editable.nil?
        load
      end
      if self.pmr.owner
        v = self.pmr.owner.name
      else
        v = "Unknown"
      end
      css_class, title, editable = [ owner_css, owner_message, owner_editable ]
      {
        :css_class => css_class,
        :title => title,
        :editable => editable,
        :name => v,
        :width => Retain::Fields.field_width(:pmr_owner_name)
      }
    end
    
    ##
    # Returns a similar hash as validate_owner except for the resolver
    def validate_resolver(user)
      if resolver_editable.nil?
        load
      end
      if self.pmr.resolver
        v = self.pmr.resolver.name
      else
        v = "Unknown"
      end
      css_class, title, editable = [ resolver_css, resolver_message, resolver_editable ]
      {
        :css_class => css_class,
        :title => title,
        :editable => editable,
        :name => v,
        :width => Retain::Fields.field_width(:pmr_resolver_name)
      }
    end
    
    ##
    # Returns a similar hash as validate_owner except for the next
    # queue.
    def validate_next_queue(user)
      if next_queue_editable.nil?
        load
      end
      v = pmr.next_queue.nil? ? "blank" : pmr.next_queue.to_param
      css_class, title, editable = [ next_queue_css, next_queue_message, next_queue_editable ]
      {
        :css_class => css_class,
        :title => title,
        :editable => editable,
        :name => v,
        :width => (Retain::Fields.field_width(:next_queue) + 1 # +1 for commma
                   Retain::Fields.field_width(:h_or_s) + 1 +
                   Retain::Fields.field_width(:next_center))
      }
    end

    ##
    # Returns the type of call.  Either "Primary", "Sec 1", "Sec 2",
    # "Sec 3", or "Backup"
    def type
      # If we know for sure its a backup
      if self.p_s_b == "B"
        return "Backup"
      else
        pmr = self.pmr
        param = self.to_param
        # Otherwise, try and figure out
        case param
        when pmr.primary_param
          return "Primary"
        when pmr.secondary_1_param
          return "Sec 1"
        when pmr.secondary_2_param
          return "Sec 2"
        when pmr.secondary_3_param
          return "Sec 3"
        else
          return "Backup"
        end
      end
    end

    ##
    # Returns true if call is dispatched to.
    def is_dispatched
      (self.call_control_flag_1 & 2) == 2
    end

    ##
    # Returns the name of the person dispatched to the call.
    def dispatched_employee_name
      Combined::Registration.find_or_initialize_by_signon(dispatched_employee).name
    end

    ##
    # Under initial response guidelines this routine is called to
    # determine when the call entered the center.
    def center_entry_time(center = queue.center)
      if sig = center_entry_sig(center)
        sig.date
      else
        pmr.create_time
      end
    end
    once :center_entry_time

    ##
    # Returns the signature for the CR that put the call into the
    # designated center
    def center_entry_sig(center = queue.center)
      # We return the last signature for a call requeue for the
      # primary (ptype == '-') that is not from within the center.
      sig = pmr.signature_line_stypes('CR').inject(nil) { |prev, s|
        if (s.ptype == '-') && (s.center != center.center)
          s
        else
          prev
        end
      }
      sig
    end
    once :center_entry_sig

    ##
    # The current definition of when initial response is needed is
    # every time the call is queued back to the center.  In theory,
    # this applies to world trade and not U.S.  For U.S., I don't have
    # a clear definition but in practical terms it is the same since
    # PMRs are never queued out of the center.
    #
    # For secondary and backups, needs initial response is always
    # false.
    #
    # For the primary, we run through the signature lines looking for
    # CR's of the primary setting with the center for the center *not*
    # equal to the center the call is on and we set +ret+ to +true+.
    # The last of these will be the requeue to the current location.
    # If we find a CT signature line after this with the same center,
    # we turn +ret+ back to +false+.  After all the signature lines
    # are processed, we return +ret+.  Note that +center+ in this case
    # is the center that the call (which is the primary call) is
    # currently in.
    def needs_initial_response?
      # logger.debug("CHC: needs_initial_response '#{p_s_b}'")
      return false if p_s_b != 'P'
      # logger.debug("CHC: needs_initial_response still here")
      center = queue.center.center
      ret = false
      pmr.signature_lines.each do |sig|
        # logger.debug("CHC: stype=#{sig.stype} ptype=#{sig.ptype}")
        # Set ret to true for any requeue of the primary.  The last
        # one will be the requeue to the current location.
        if sig.stype == 'CR' && sig.ptype == '-' && sig.center != center
          # logger.debug("CHC: CR line at #{sig.date}")
          ret = true
        end
        # Set ret to false for any CT from this center.
        if sig.stype == 'CT'  && sig.center == center
          # logger.debug("CHC: CT line at #{sig.date}")
          ret = false
        end
      end
      # Ret will be the last toggle from the above two conditions.
      ret
    end
    once :needs_initial_response?

    private

    ##
    # The validate_owner_private, validate_resolver_private, and
    # validate_next_queue_private were created first.  They each
    # return a three value tuple of a css_class, some text, and a
    # boolean if the field is editable.  These routines were called at
    # view time.  (These routines are not used any more.)
    #
    # New routines will take their place and will be called when the
    # call is fetched and stored in the database.  I decided to
    # compute this at fetch time instead of display time because the
    # long term goal is to have a daemon trying to keep the database
    # fresh so all the queues can come straight from the database
    # rather than waiting on Retain.  Plus, almost always, a call or
    # PMR is fetched so it can be displayed so it will be rare that a
    # call is fetched and not displayed.
    #
    # The new process pretty much says that the owner is always
    # valid.  The only exception is if it blank.
    def validate_owner_private(user)
      pmr_owner = pmr.owner
      # A blank owner is a bad dog.
      if pmr_owner.signon.blank?
        return [ "wag-wag", "Owner should not be blank", true ]
      end
      return [ "normal", "PMR Owner assumed valid", true]
    end

    ##
    # See validate_owner_private except this is for the resolver
    def validate_resolver_private(user)
      queue = self.queue
      user_center = user.center(queue.h_or_s)
      if user_center.center != queue.center.center
        return [ "normal", "Queue outside center not editable or judged", true]
      end

      # Lets deal with backups and secondarys.  As far as I know, they
      # are not editable for any reason.
      p_s_b = self.p_s_b
      if p_s_b == 'S' || p_s_b == 'B'
        return ["normal", "Resolver for secondary/backup not editable or judged", true ]
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

    ##
    # See validate_owner_private except this is for the next queue
    def validate_next_queue_private(user)
      queue = self.queue
      user_center = user.center(queue.h_or_s)
      if user_center.center != queue.center.center
        return [ "normal", "Queue outside center not editable or judged", true]
      end

      # Lets deal with backups and secondarys.  As far as I know, they
      # are not editable for any reason.
      p_s_b = self.p_s_b
      if p_s_b == 'S' || p_s_b == 'B'
        return ["normal", "Next Queue for secondary/backup not editable or judged", true ]
      end
      
      pmr = self.pmr
      # World Trade, next queue is always o.k.
      # TODO Actually, this isn't true.  It resolver or next queue get
      # clobbered they are not o.k.  We might could add code to detect that.
      if pmr.country != "000"
        return ["normal", "Next Queue for WT not editable or judged", true ]
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
        return [ "good", "Team queues are not editable or judged", true ]
      end

      # Personal queue set to next queue... bad dog.
      if next_queue.id == queue.id
        return [ "wag-wag", "Next queue set to personal queue", true ]
      end

      # Queues outside of center can't be good -- can they?
      if pmr.next_center.center != queue.center.center
        return [ "warn", "Next queue outside of center is probably wrong", true ]
      end
      
      unless next_queue.queue_infos.empty?
        return [ "warn", "Next queue is a personal queue", true ]
      end

      return [ "good", "I can not find anything to complain about", true ]
    end

    ##
    # Called when the call is fetched to compute the same triple as
    # before: the css_value, the title, and the editable flag.  These
    # are now saved in the database record as Cached::Call#owner_css
    # and others.
    #
    # For primary PMRs, if we have the owner of the queue where the
    # primary resides, then we want that person to be the owner of the
    # PMR.  This is for WT and US.
    def compute_owner_private
      pmr_owner = pmr.owner
      # A blank owner is a bad dog.
      if pmr_owner.nil? || pmr_owner.signon.blank?
        return [ "wag-wag", "Owner should not be blank", true ]
      end
      return [ "normal", "PMR Owner assumed valid", true]
    end

    ##
    # Similar to compute_owner_private except for the resolver fields.
    # In this case, we look at the all of the centers for the primary
    # and secondary calls.  The resolver's software or hardware center
    # should be one of those centers.
    def compute_resolver_private
      pmr = @cached.pmr
      pmr_resolver = pmr.resolver

      # A blank resolver is a bad dog.
      if pmr_resolver.nil? || pmr_resolver.signon.blank?
        return [ "wag-wag", "Resolver should not be blank", true ]
      end

      queue = @cached.queue
      centers = [ queue.center_id,
                  pmr.sec_1_center,
                  pmr.sec_2_center,
                  pmr.sec_3_center ].uniq

      if centers.include?(pmr_resolver.software_center_id) ||
          centers.include?(pmr_resolver.hardware_center_id)
        return ["good", "At least one call in same center as resolver", true]
      end

      return [ "wag-wag", "No call in same center as resolver", true ]
    end

    ##
    # Similar to compute_owner_private except for the next queue
    # fields.
    def compute_next_queue_private
      return ["normal", "No way to determine if Next Queue is set properly", true ]

      # queue = @cached.queue

      # # Lets deal with backups and secondarys.  As far as I know, they
      # # are not editable for any reason.
      # p_s_b = @cached.p_s_b
      # if p_s_b == 'S' || p_s_b == 'B'
      #   return ["normal", "Next Queue for secondary/backup not editable or judged", true ]
      # end
      
      # pmr = @cached.pmr
      # # World Trade, next queue is always o.k.
      # # TODO Actually, this isn't true.  It resolver or next queue get
      # # clobbered they are not o.k.  We might could add code to detect that.
      # if pmr.country != "000"
      #   return ["normal", "Next Queue for WT not editable or judged", true ]
      # end

      # if pmr.next_center.nil?
      #   return [ "wag-wag", "Next Queue center is invalid", true ]
      # end

      # next_queue = pmr.next_queue
      # if next_queue.nil?
      #   return [ "wag-wag", "Next Queue queue name is invalid", true ]
      # end

      # # We are going to assume that if we have no queue info records
      # # on this queue, then it is a team queue.
      # if (infos = queue.queue_infos).empty?
      #   return [ "good", "Team queues are not editable or judged", true ]
      # end

      # # Personal queue set to next queue... bad dog.
      # if next_queue.id == queue.id
      #   return [ "wag-wag", "Next queue set to personal queue", true ]
      # end

      # # Queues outside of center can't be good -- can they?
      # if pmr.next_center.center != queue.center.center
      #   return [ "warn", "Next queue outside of center is probably wrong", true ]
      # end
      
      # unless next_queue.queue_infos.empty?
      #   return [ "warn", "Next queue is a personal queue", true ]
      # end

      # return [ "good", "I can not find anything to complain about", true ]
    end
    
    ##
    # Load (fetch) the call from Retain and push the new values into
    # the database.
    def load
      # logger.debug("CMB: load for #{self.to_param}")
      # Pull the fields we need from the cached record into an options_hash
      queue = @cached.queue
      options_hash = {
        :queue_name => queue.queue_name,
        :h_or_s => queue.h_or_s,
        :center => queue.center.center,
        :ppg => @cached.ppg
      }
      # logger.debug("CMB: options_hash = #{options_hash.inspect}")

      # :group_request is a special case
      group_request = Combined::Call.retain_fields.map { |field| field.to_sym }
      # logger.debug("CMB: group_request = #{group_request.inspect}")
      options_hash[:group_request] = [ group_request ]

      # Create retain object
      call = Retain::Call.new(retain_user_connection_parameters, options_hash)

      # Touch to force a fetch from Retain
      begin
        call.send(group_request[0])
      rescue Retain::SdiReaderError => e
        if e.sr == 65 && e.ex == 11
          # This may cause another exception but I don't think it
          # will.  If it does, the to_param can be manually coded.
          raise CallNotFound.new(to_param)
        else
          raise e
        end
      end

      # Make or find Cached PMR
      @cached.pmr = Pmr.find_existing_pmr(call).unwrap_to_cached

      # Make or find customer
      cust_options = {
        :country => call.country,
        :customer_number => call.customer_number
      }
      @cached.pmr.customer = Cached::Customer.find_or_new(cust_options)

      # logger.debug("CMB: TMP customer_time_zone_adj = #{call.customer_time_zone_adj}")
      # logger.debug("CMB: TMP time_zone_code = #{call.time_zone_code}")

      # Update call record
      #
      # This comment applies to most of the combined models.
      # We gather the options that go into the database record from
      # the call and assign them to the database record.  We then ask
      # if anything has changed.  If something has changed, when we
      # mark last_fetched with the current time.  We then fix the
      # dirty flag as false, force the updated_at to be now, and then
      # do a save.
      # The net result will be that the updated_at timestamp will be
      # the time that we last checked retain.  The last_fetched will
      # be the time when Retain last changed.
      #
      options = self.class.cached_class.options_from_retain(call)
      @cached.attributes = options
      if @cached.changed?
        @cached.last_fetched = Time.now
      end
      @cached.dirty = false
      @cached.updated_at = Time.now

      @cached.owner_css,
      @cached.owner_message,
      @cached.owner_editable = compute_owner_private

      @cached.resolver_css,
      @cached.resolver_message,
      @cached.resolver_editable = compute_resolver_private

      @cached.next_queue_css,
      @cached.next_queue_message,
      @cached.next_queue_editable = compute_next_queue_private
      @cached.save
    end
  end
end
