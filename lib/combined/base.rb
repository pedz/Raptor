# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require 'singleton'

module Combined
  # Exception Raised by Combined::Queue::from_param! if the specified
  # queue was not found to be valid in Retain.
  class QueueNotFound < Exception
    # spec is the queue that was being searched for.
    def initialize(spec)
      super("Queue #{spec} Not Found")
    end
  end
  
  # Exception Raised by Combined::Center::from_param! if the specified
  # queue was not found to be valid in Retain.
  class CenterNotFound < Exception
    # spec is the center that was being searched for.
    def initialize(spec)
      super("Center #{spec} Not Found")
    end
  end
  
  # Exception Raised by Combined::Call::from_param! if the specified
  # queue was not found to be valid in Retain.
  class CallNotFound < Exception
    # spec is the call that was being searched for.
    def initialize(spec)
      super("Call #{spec} Not Found")
    end
  end
  
  # Exception Raised by Combined::Pmr::from_param! if the specified
  # queue was not found to be valid in Retain.
  class PmrNotFound < Exception
    # spec is the PMR that was being searched for.
    def initialize(spec)
      super("PMR #{spec} Not Found")
    end
  end
  
  # This is a debugging tool to see if there were recursive calls to
  # load and if there were, what was the path.
  class LoadStack
    include Singleton
    
    # Called from Combined::Base.call_load to push s on to a
    # (singleton) stack.  s is the class and param of the instance for
    # each load is about to be called.  If a duplicate if found, the
    # current stack is put into the error log.
    def push(s)
      @stack ||= []
      if @stack.include?(s)
        Rails.logger.error("Load called for #{s} again:\n#{@stack.join("\n")}\n#{caller.join("\n")}")
      end
      @stack.push(s)
    end
    
    # Remove what was last pushed.
    def pop
      @stack.pop
    end
  end

  class Base
    # Initialized in config/initializers/loggers.rb
    cattr_accessor :logger

    include Common

    class << self
      include Combined::ClassCommon

      # Create a class instance getters to get an array of Retain
      # fields, all fields in the db class, the skipped fields, and
      # the subclass.
      attr_reader :subclass

      # skipped_fields are fields in the database record that are not
      # in Retain.  These will be any associations.  Maybe I should
      # automatically include those... hmmm...
      attr_reader :skipped_fields

      # extra fields are fields that the Retain fetch needs to add
      # in.  For example, when a queue is fetched, we get the call's
      # ppg field.  But we also want the problem, branch, and country
      # for the pmr.  So, we add those in.  This, in the very general,
      # case could not be done automatically because as things cascade
      # down (queue -> call -> pmr -> owner id -> owner phone number,
      # etc)
      attr_reader :extra_fields

      # retain fields are the result of db_fields minus skipped_fields
      # plus extra_fields
      attr_reader :retain_fields

      include ClassNameUtils
      
      # Returns the equivalent cached class.
      # e.g. Combined::Pmr.unwrap_to_cached returns Cached::Pmr.
      def unwrap_to_cached
        # logger.debug("CMB: class unwrap <#{self.class}:#{self.object_id}>")
        @cached_class
      end
    
      # The fields in the cached database class that are not
      # associations
      def db_fields
        (@db_fields ||= [cached_class.db_fields])[0]
      end
      
      # The associations in the cached database class
      def db_associations
        (@db_associations ||= [cached_class.db_associations])[0]
      end
      
      # The combined model specifies which of the retain fields are
      # used as the keys. e.g. :center is the key for a center.  Note
      # that this is only the fields in the db record (a subset of
      # db_fields).
      def set_db_keys(*args)
        a = [ *args ]
        # logger.debug("CMB: db_keys for #{self} set to #{a.inspect}")
        @db_keys = a
        add_skipped_fields(*args)
      end
      attr_reader :db_keys

      # Method called when a subclass is being defined to set the
      # db_constants A db_constant are fields with rarely change so
      # exclude being fetched simply because the record is old.
      def set_db_constants(*args)
        a = [ *args ]
        # logger.debug("CMB: db_constants for #{self} set to #{a.inspect}")
        a.each do |name|
          if db_fields.include?(name)
            # logger.debug("CMB: define #{name} as constant field")
            class_eval("def #{name}
                    # logger.debug(\"CMB: #{name} called as constant field for \#{self.to_s}\")
                    unless !(temp = @cached.#{name}).nil? || cache_valid?
                      call_load
                      temp = @cached.#{name}
                    end
                    return temp
                  end", __FILE__, __LINE__ - 6)
          end
          if db_associations.include?(name)
            # logger.debug("CMB: define #{name} as constant association")
            class_eval("def #{name}
                    # logger.debug(\"CMB: #{name} called as constant association for \#{self.to_s}\")
                    unless !(temp = @cached.#{name}).nil? || cache_valid?
                      call_load
                      temp = @cached.#{name}
                    end
                    temp.wrap_with_combined
                  end", __FILE__, __LINE__ - 6)
          end
        end
        @db_constants = a
      end

      # db_constants are fields which will never change (or rarely
      # change) once they have been filled in.  So, we do not ask if
      # the cache is valid.  BUT... in the case of values which are
      # not present like the software center for a registration, we do
      # not want to constantly fetch the registration just because the
      # software center is null.  So, if the cache is valid, we do not
      # fetch it.
      attr_reader :db_constants

      # Returns a subset of options by returning only those which are
      # also in db_keys.
      def keys_only(options)
        Hash[ *options.select { |k, v| db_keys.include?(k) }.flatten ]
      end

      # Returns a subset of options by returning only those which are
      # also in db_fields.
      def fields_only(options)
        Hash[ *options.select { |k, v| db_fields.include?(k) }.flatten ]
      end
      
      # Called when a subclass is defined to add fields whcih are
      # skipped in the Retain queries.  These would be fields in the
      # database Cached record that do not come from Retain or come
      # from Retain via a different name.
      def add_skipped_fields(*args)
        @skipped_fields += [ *args ]
        @retain_fields  -= [ *args ]
        args.each do |name|
          class_eval("def #{name}; @cached.#{name}; end", __FILE__, __LINE__)
        end
      end

      # Called when the subclass is defined to add extra fields to the
      # Retain query.
      def add_extra_fields(*args)
        @extra_fields += [ *args ]
        @retain_fields += [ *args ]
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

      # Takes param and split it at commas into a list of words.
      def param_to_options(param)
        words_to_options(param.split(/,/))
      end
      
      # Return the current connection parameters that has been set for
      # the current request.
      def retain_user_connection_parameters
        Retain::Logon.instance.get
      end

      # A convenience method used to make particular methods as
      # "once".  Such methods will cache their results in an attribute
      # and return that when called again within the same request.
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
    end                         # end of class methods
    
    # Hooks in to the to_json chain for Combined models so that
    # calling to_json results in an up to date version before being
    # sent out.
    def to_json_with_defaults(options)
      call_load unless cache_valid?
      @cached.to_json(options)
    end
    alias_method_chain :to_json, :defaults

    # new for the Combined subclasses takes a hash of options or an
    # instance of the equivalent Cached class.  Creates the underlying
    # Cached model and then wraps it upon return.  Also retrieves the
    # current connection parameters and stores them in an attribute.
    def initialize(arg = { })
      super()
      @retain_user_connection_parameters = Retain::Logon.instance.get
      if @retain_user_connection_parameters.nil?
        raise "combined object created before retain_user_connection_paramters set"
      end
      if arg.kind_of? Hash
        @cached = self.class.cached_class.new(arg.unwrap_to_cached)
      else
        @cached = arg
      end
    end
      
    # Returns the retain connection paramters active when the model
    # was created.
    def retain_user_connection_parameters
      @retain_user_connection_parameters
    end

    # Mark the cached model as invalid.  This will cause a load to be
    # done when the next field of the model is touched.
    def mark_cache_invalid
      @invalid_cache = true
    end

    # Asks if the model has been marked as invalid.
    def is_invalid?
      @invalid_cache
    end

    # Returns the cached model that has been wrapped by the combined
    # model.
    def unwrap_to_cached
      # logger.debug("CMB: unwrap <#{self.class}:#{self.object_id}>")
      @cached
    end

    # Returns the expire_time for the class.
    def expire_time
      self.class.expire_time
    end

    # Returns the xml for the combined model.  Its curious that it
    # does not make sure that the cache is up to date (bug?).  root is
    # set to the class name.
    def to_xml(options = { }, &block)
      options[:root] ||= self.class.to_s
      @cached.to_xml(options, &block)
    end

    # Routine added so that AsyncRequest has an easy place to call
    # that will test the cache to see if a load would be a good thing
    # to do or not.
    def load_if_stale
      call_load unless cache_valid?
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
    # 1. If @invalid_cache is true, return false.  I believe this is
    #    no longer used.  The @invalid_cache attribute was only held
    #    in the instance and not pushed to the database like the dirty
    #    flag is.
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
        # logger.debug("CMB: #{self.to_s} cache_valid?: return true: expire set to :never")
        return true
      end
      
      if @cached.respond_to?("dirty") && @cached.dirty
        # logger.debug("CMB: #{self.to_s} cache_valid?: return false: @cached.dirty is true")
        return false
      end
      
      # If we are not cached at all, then cache is invalid
      if (updated_at = @cached.updated_at).nil?
        # logger.debug("CMB: #{self.to_s} cache_valid?: return false: updated_at is nil")
        return false
      end

      # If the udpated at is equal to the creted at, that might mean
      # that we have never really fetched the whole object.
      if updated_at == created_at
        # logger.debug("CMB: #{self.to_s} cache_valid?: return false: updated_at == created_at")
        return false
      end
      
      # See if expire_time is a symbol pointing to a method
      if expire.is_a?(Symbol) && self.respond_to?(expire)
        value = self.send(expire)
        # logger.debug("CMB: #{self.to_s} cache_valid? return result from #{expire} of #{value}")
        return value
      end

      # If item has been explicitly marked to be re-fetched
      if @invalid_cache
        # logger.debug("CMB: #{self.to_s} cache_valid?: return false: invalid_cache set")
        return false
      end
      
      # If this has already been loaded, then cache must be valid
      if @loaded
        # logger.debug("CMB: #{self.to_s} cache_valid?: return true: @loaded is set")
        return true
      end

      # else, return if cache time has expired or not
      r = updated_at > expire.ago
      # logger.debug("CMB: #{self.to_s} cache_valid?: updated_at:#{updated_at}, " +
      #              "expire:#{expire}, expire.ago:#{expire.ago}, " +
      #              "now:#{Time.now}, r:#{r}")
      r
    end

    private

    # Called when a subclass is first created.  This sets up getter
    # methods for all of the cached models database fields and
    # associations.
    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass
        
        # Specify default extra fields and skipped fields
        @skipped_fields = [ :id, :created_at, :updated_at ]
        @skipped_fields += [ :dirty ] if db_fields.include?(:dirty)
        @skipped_fields += [ :last_fetched ] if db_fields.include?(:last_fetched)
        @extra_fields = [ ]

        # Set up fields fetched from retain
        @retain_fields = db_fields - @skipped_fields + @extra_fields

        # Define getter methods for each field
        # logger.debug("CMB: define fields and associations for #{subclass}")
        db_fields.each do |name|
          if @skipped_fields.include?(name)
            eval("def #{name}
                    # logger.debug(\"CMB: #{name} called as skipped field for \#{self.to_s}\")
                    @cached.#{name}
                  end", nil, __FILE__, __LINE__ - 3)
          else
            eval("def #{name}
                    # logger.debug(\"CMB: #{name} called as field for \#{self.to_s}\")
                    unless cache_valid? && !(temp = @cached.#{name}).nil?
                      call_load
                      temp = @cached.#{name}
                    end
                    return temp
                  end", nil, __FILE__, __LINE__ - 7)
          end
        end

        # Define getter methods for each association
        # For associations, we accept a null value as possible.  So,
        # we only ask if the cache is valid before calling load.
        db_associations.each do |name|
          eval("def #{name}
                  # logger.debug(\"CMB: #{name} called as association for \#{self.to_s}\")
                  call_load unless cache_valid?
                  @cached.#{name}.wrap_with_combined
                end", nil, __FILE__, __LINE__ - 4)
        end
      }
    end

    # if Combined::Base::DB_ONLY is set, then a fetch to Retain is
    # never done.  Otherwise load is called.  After load returns,
    # @invalid_cache is marked as false and @loaded is marked as true.
    # dirty is pushed to the database as false in the load method
    # being called.
    def call_load
      # logger.debug("CMB: db only = #{DB_ONLY}")
      unless DB_ONLY
        s = "#{self.class.to_s}:#{self.to_param}"
        LoadStack.instance.push(s)
        begin
          load
        ensure
          LoadStack.instance.pop
        end
      end
      @invalid_cache = false
      @loaded = true
    end
  end
end
