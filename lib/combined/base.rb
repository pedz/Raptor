module Combined
  class QueueNotFound < Exception
    def initialize(spec)
      super("Queue #{spec} Not Found")
    end
  end
  
  class CenterNotFound < Exception
    def initialize(spec)
      super("Center #{spec} Not Found")
    end
  end
  
  class CallNotFound < Exception
    def initialize(spec)
      super("Call #{spec} Not Found")
    end
  end
  
  class PmrNotFound < Exception
    def initialize(spec)
      super("PMR #{spec} Not Found")
    end
  end
  
  class Base
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
      
      # I think these are redundant...?
      # def cached_class_name
      #   # logger.debug("CMB: class name is #{self.to_s}")
      #   @cached_class_name ||= "Cached::" + self.to_s.sub(/.*::/, "")
      # end
      # 
      # def cached_class
      #   @cached_class ||= cached_class_name.constantize
      # end

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
      
      def add_non_retain_associations(*list)
        a = [ *list ]
        logger.debug("CMB: non_retain_associations for #{self} set to #{a.inspect}")
        a.each do |name|
          logger.debug("CMB: defining #{name} as non_retain_association")
          class_eval("def #{name}; @cached.#{name}.wrap_with_combined; end", __FILE__, __LINE__)
        end
        @non_retain_associations += a
      end
      attr_reader :non_retain_associations

      # The combined model specifies which of the retain fields are
      # used as the keys. e.g. :center is the key for a center.  Note
      # that this is only the fields in the db record (a subset of
      # db_fields).
      def set_db_keys(*args)
        a = [ *args ]
        logger.debug("CMB: db_keys for #{self} set to #{a.inspect}")
        @db_keys = a
      end
      attr_reader :db_keys

      # db_constants are fields which will never change (or rarely
      # change) once they have been filled in.  So, we do not ask if
      # the cache is valid.  BUT... in the case of values which are
      # not present like the software center for a registration, we do
      # not want to constantly fetch the registration just because the
      # software center is null.  So, if the cache is valid, we do not
      # fetch it.
      def set_db_constants(*args)
        a = [ *args ]
        logger.debug("CMB: db_constants for #{self} set to #{a.inspect}")
        a.each do |name|
          if db_fields.include?(name)
            logger.debug("CMB: define #{name} as constant field")
            class_eval("def #{name}
                    logger.debug(\"CMB: #{name} called as constant field for \#{self.to_s}\")
                    unless !(temp = @cached.#{name}).nil? || cache_valid?
                      call_load
                      temp = @cached.#{name}
                    end
                    return temp
                  end", __FILE__, __LINE__ - 6)
          end
          if db_associations.include?(name)
            logger.debug("CMB: define #{name} as constant association")
            class_eval("def #{name}
                    logger.debug(\"CMB: #{name} called as constant association for \#{self.to_s}\")
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
      attr_reader :db_constants

      def keys_only(options)
        Hash[ *options.select { |k, v| db_keys.include?(k) }.flatten ]
      end

      def fields_only(options)
        Hash[ *options.select { |k, v| db_fields.include?(k) }.flatten ]
      end
      
      def add_skipped_fields(*args)
        @skipped_fields += [ *args ]
        @retain_fields  -= [ *args ]
        args.each do |name|
          class_eval("def #{name}; @cached.#{name}; end", __FILE__, __LINE__)
        end
      end

      def add_extra_fields(*args)
        @extra_fields += [ *args ]
        @retain_fields += [ *args ]
      end

      attr_reader :expire_time

      # We expect a duration but :never is also accepted
      def set_expire_time(duration)
        @expire_time = duration
      end

      def param_to_options(param)
        words_to_options(param.split(/,/))
      end
    end

    # new for the Combined subclasses takes a hash of options or an
    # instance of the equivalent Cached class
    def initialize(arg = { })
      super()
      if arg.kind_of? Hash
        @cached = self.class.cached_class.new(arg.unwrap_to_cached)
      else
        @cached = arg
      end
    end

    def mark_cache_invalid
      @invalid_cache = true
    end

    def cached
      return @cached
    end

    def unwrap_to_cached
      # logger.debug("CMB: unwrap <#{self.class}:#{self.object_id}>")
      @cached
    end

    def expire_time
      self.class.expire_time
    end

    def to_xml(options = { }, &block)
      options[:root] ||= self.class.to_s
      @cached.to_xml(options, &block)
    end

    private

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass
        
        # Specify default extra fields and skipped fields
        @skipped_fields = [ :id, :created_at, :updated_at ]
        @skipped_fields += [ :dirty ] if db_fields.include?(:dirty)
        @extra_fields = [ ]
        @non_retain_associations = [ ]

        # Set up fields fetched from retain
        @retain_fields = db_fields - @skipped_fields + @extra_fields

        # Define getter methods for each field
        logger.debug("CMB: define fields and associations for #{subclass}")
        db_fields.each do |name|
          if @skipped_fields.include?(name)
            eval("def #{name}
                    logger.debug(\"CMB: #{name} called as skipped field for \#{self.to_s}\")
                    @cached.#{name}
                  end", nil, __FILE__, __LINE__ - 3)
          else
            eval("def #{name}
                    logger.debug(\"CMB: #{name} called as field for \#{self.to_s}\")
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
          if @non_retain_associations.include?(name)
            logger.debug("CMB: defining #{name} as non_retain_association")
            eval("def #{name}; @cached.#{name}.wrap_with_combined; end", __FILE__, __LINE__)
          else
            logger.debug("CMB: defining #{name} as association")
            eval("def #{name}
                    logger.debug(\"CMB: #{name} called as association for \#{self.to_s}\")
                    call_load unless cache_valid?
                    @cached.#{name}.wrap_with_combined
                  end", nil, __FILE__, __LINE__ - 4)
          end
        end
      }
    end

    def call_load
      logger.debug("CMB: db only = #{DB_ONLY}")
      load unless DB_ONLY
      @invalid_cache = false
      @loaded = true
    end
    
    def cache_valid?
      if @cached.respond_to?("dirty") && @cached.dirty
        logger.debug("CMB: #{self.to_s} cache_valid?: return false: @cached.dirty is true")
        return false
      end
      
      # If we are not cached at all, then cache is invalid
      if (updated_at = @cached.updated_at).nil?
        logger.debug("CMB: #{self.to_s} cache_valid?: return false: updated_at is nil")
        return false
      end

      # If data type says cache never expires then we are good to go
      if (expire = expire_time) == :never
        logger.debug("CMB: #{self.to_s} cache_valid?: return true: expire set to :never")
        return true
      end
      
      # If the udpated at is equal to the creted at, that might mean
      # that we have never really fetched the whole object.
      if updated_at == created_at
        logger.debug("CMB: #{self.to_s} cache_valid?: return false: updated_at == created_at")
        return false
      end
      
      # See if expire_time is a symbol pointing to a method
      if expire.is_a?(Symbol) && self.respond_to?(expire)
        value = self.send(expire)
        logger.debug("CMB: #{self.to_s} cache_valid? return result from #{expire} of #{value}")
        return value
      end

      # If item has been explicitly marked to be re-fetched
      if @invalid_cache
        logger.debug("CMB: #{self.to_s} cache_valid?: return false: invalid_cache set")
        return false
      end
      
      # If this has already been loaded, then cache must be valid
      if @loaded
        logger.debug("CMB: #{self.to_s} cache_valid?: return true: @loaded is set")
        return true
      end

      # else, return if cache time has expired or not
      r = updated_at > expire.ago
      logger.debug("CMB: #{self.to_s} cache_valid?: updated_at:#{updated_at}, " +
                   "expire:#{expire}, expire.ago:#{expire.ago}" +
                   "now:#{Time.now}, r:#{r}")
      r
    end
  end
end
