# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Cached
  class Base < ActiveRecord::Base
    # Initialized in config/initializers/loggers.rb
    cattr_accessor :logger

    class << self
      # list of fields as symbols in this record.
      def db_fields
        (@db_fields ||= [columns.map { |c| c.name.to_sym }])[0]
      end
      
      # list of associations as symbols in this record.
      def db_associations
        (@db_associations ||= [reflections.values.map{ |r| r.name }])[0]
      end
      
      def db_keys
        (@db_keys ||= [combined_class.db_keys])[0]
      end
      
      def keys_only(options)
        r = Hash[ *options.select { |k, v| db_keys.include?(k) }.flatten ]
        # logger.debug("CHC: keys_only for #{self} returning: #{r.inspect}")
        r
      end
      
      # Takes a hash and returns a hash containing only fields in the
      # db record.
      def fields_only(options)
        r = Hash[ *options.select { |k, v| db_fields.include?(k) }.flatten ]
        # logger.debug("CHC: fields_only for #{self} returning: #{r.inspect}")
        r
      end
      
      def once(*ids)
        for id in ids
          clean_id_name = "__UNIQUE__#{id.to_s.sub(/\?/, '')}"
          module_eval <<-mod_end
	    alias_method :#{clean_id_name}, :#{id.to_s}
	    private :#{clean_id_name}
	    def #{id.to_s}(*args, &block)
	      (@#{clean_id_name} ||= [#{clean_id_name}(*args, &block)])[0]
	    end
          mod_end
        end
      end
      private :once

      # Return a hash of options based upon the Retain record
      def options_from_retain(retain)
        # logger.debug("CHC: options_from_retain retain.fields=#{retain.fields.inspect}")
        # logger.debug("CHC: options_from_retain db_fields=#{db_fields.inspect}")
        a = db_fields.select { |sym|
          retain.has_key?(sym)
        }.map { |sym|
          [ sym, retain.send(sym) ]
        }.flatten
        # logger.debug("CHC: options from retain are #{a.inspect}")
        Hash[ * a ]
      end
      
      def find_or_new(options)
        find(:first, :conditions => keys_only(options)) || new(fields_only(options))
      end
      
      # Fetch or create the DB record from a Retain record
      def find_or_new_from_retain(retain)
        # Get the fields for the cached class
        # logger.debug("CHC: new #{@subclass} from retain")
        options = options_from_retain(retain)
        find_or_new(options)
      end
      
      # Very similar to find_or_new except calls valid? in the Retain
      # class
      def from_options(retain_user_connection_parameters, options)
        # logger.debug("CHC: from_options #{self} with #{options.inspect}")
        temp = find(:first, :conditions => keys_only(options))
        if temp.nil? && (rtemp = retain_class.valid?(retain_user_connection_parameters, options))
          # currently just used for PMRs.  Allows the valid? to return
          # a retain object that fills in more fields such as the
          # creation date of a PMR.
          unless rtemp == true
            options.merge!(options_from_retain(rtemp))
          end
          temp = new(fields_only(options))
        end
        temp
      end
      alias :new_from_options :from_options
    
      # Calls new_from_options which calls valid?
      def create_from_options(retain_user_connection_parameters, options)
        r = new_from_options(retain_user_connection_parameters, options)
        r.save if r && r.new_record?
        r
      end

      def inherited(subclass)
        super(subclass)
        subclass.extend(ClassNameUtils)

        subclass.class_eval {
          # Remember our name
          @subclass = subclass
        }
      end

      ##
      # Set in each of the subclasses to a value.  Legal values are:
      #
      # 1. :never which means that the cached value never expires.
      #
      # 1. A time period such as 30.minutes which means that the
      #    cached value expires in thirty minutes.
      #
      # 1. A symbol for a method that returns if the cache is valid or
      #    not.
      #
      attr_reader :expire_time

      # Called when a subclass is defined to set the expire_time for
      # that model.
      def set_expire_time(duration)
        @expire_time = duration
      end
    end
    
    # Returns the expire_time for the class.
    def expire_time
      self.class.expire_time
    end

    ##
    # Returns true if the cache is considered valid.
    #
    # 1. If expire_time is a symbol and the record responds to that
    #    symbol, then we call it and return the value that it
    #    returns. This is used for queue_infos which should not be
    #    "cached" at all and text_lines which are fully initialized
    #    when they are created.
    #
    # 1. If the dirty bit is set, return false.  This happens when an
    #    update occurs through Raptor because we know that Retain has
    #    been changed.
    #
    # 1. If updated_at is nil then we have never fetched the record so
    #    return false.
    #
    # 1. If the expire_time is set to :never, return true.
    #
    # 1. If updated_at is equal to created_at then that implies that
    #    we might not have ever fetched the whole record so return
    #    false.
    #
    # 1. If @loaded is true, then return true.  @loaded is set to true
    #    in the load path.  There are times when fetching the record
    #    from Retain results in a record that still looks out of date.
    #    For example, we can not always fetch a DR.  It is pointless
    #    to keep asking Retain for it when the request isn't helping.
    #
    # 1. Finally... we return updated_at > exire_time.ago (e.g. if
    #    expire_time is 5.days then return true if updated_at is more
    #    recent (greater than) 5.days.ago
    def cache_valid?
      # If data type says cache never expires then we are good to go
      if (expire = expire_time) == :never
        # logger.debug("CHC: #{self.to_s} cache_valid?: return true: expire set to :never")
        return true
      end
      
      if respond_to?("dirty") && dirty
        # logger.debug("CHC: #{self.to_s} cache_valid?: return false: dirty is true")
        return false
      end
      
      # If we are not cached at all, then cache is invalid
      if updated_at.nil?
        # logger.debug("CHC: #{self.to_s} cache_valid?: return false: updated_at is nil")
        return false
      end

      # If the udpated at is equal to the creted at, that might mean
      # that we have never really fetched the whole object.
      if updated_at == created_at
        # logger.debug("CHC: #{self.to_s} cache_valid?: return false: updated_at == created_at")
        return false
      end
      
      # See if expire_time is a symbol pointing to a method
      if expire.is_a?(Symbol) && self.respond_to?(expire)
        value = self.send(expire)
        # logger.debug("CHC: #{self.to_s} cache_valid? return result from #{expire} of #{value}")
        return value
      end

      # else, return if cache time has expired or not
      r = updated_at > expire.ago
      # logger.debug("CHC: #{self.to_s} cache_valid?: updated_at:#{updated_at}, " +
      #              "expire:#{expire}, expire.ago:#{expire.ago}, " +
      #              "now:#{Time.now}, r:#{r}")
      r
    end

    # Determine the priority of the asynchronous request for this
    # object.  If the object has a last_fetched field and it is null,
    # then this object has never been fetched.  Its priority will be
    # :high.  If the object has been fetched but is stale according to
    # its Combined class' criteria, then the priority will be :med.
    # Otherwise, if force is true, the priority will be :low while if
    # force is not true, the priority will be :none.
    def async_priority(force = false)
      # If object has never fully been fetched
      return  1024 if respond_to?(:last_fetched) && last_fetched.nil?

      # if object is out of date
      return   512 unless cache_valid?

      # if requestor asked for a forced refresh
      return     0 if force

      # else none of the above.
      return :none
    end

    def wrap_with_combined
      # logger.debug("CHC: wrap Cached <#{self.class}:#{self.object_id}>")
      @combined ||= self.class.combined_class.new(self)
    end
    alias to_combined wrap_with_combined

    # Mark the underlying cached object as dirty
    def mark_as_dirty
      if respond_to?("dirty")
        update_attributes :dirty => true
      end
    end
  end
end
