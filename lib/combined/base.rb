module Combined
  class Base

    include Common

    class << self
      include Combined::ClassCommon

      # Create a class instance getters to get an array of Retain
      # fields, all fields in the db class, the skipped fields, the
      # logger, and the subclass.
      
      # Set up logger
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

      def logger
        RAILS_DEFAULT_LOGGER
      end

      def cached_class_name
        logger.debug("class name is #{self.to_s}")
        @cached_class_name ||= "Cached::" + self.to_s.sub(/.*::/, "")
      end

      def cached_class
        @cached_class ||= cached_class_name.constantize
      end

      def unwrap_to_cached
        logger.debug("CMB: class unwrap <#{self.class}:#{self.object_id}>")
        @cached_class
      end
    
      def db_fields
        @db_fields ||= cached_class.db_fields
      end
      
      def db_associations
        @db_associations ||= cached_class.db_associations
      end
      
      def add_skipped_fields(*args)
        @skipped_fields += [ *args ]
        @retain_fields  -= [ *args ]
      end

      def add_extra_fields(*args)
        @extra_fields += [ *args ]
        @retain_fields  += [ *args ]
      end

      attr_reader :expire_time

      # We expect a duration but :never is also accepted
      def set_expire_time(duration)
        @expire_time = duration
      end
    end

    # new for the Combined subclasses takes a hash of options or an
    # instance of the equivalent Cached class
    def initialize(arg = { })
      super()
      @logger = RAILS_DEFAULT_LOGGER
      @logger.debug("CMB: <#{self.class}:#{self.object_id}> start initializing")
      how = ""
      if arg.kind_of? Hash
        @cached = self.class.cached_class.new(arg.unwrap_to_cached)
        how = "from hash"
      else
        @cached = arg
        how = "from db"
      end
      @logger.debug("CMB: <#{self.class}:#{self.object_id}> initialized #{how}")
    end

    def mark_cache_invalid
      @invalid_cache = true
    end

    def cached
      # Can not use to_s in this debugging call -- it creates an infinite loop
      logger.debug("CMB: cached method for <#{self.class}:#{self.object_id}> called.")
      return @cached
    end

    def unwrap_to_cached
      logger.debug("CMB: unwrap <#{self.class}:#{self.object_id}>")
      @cached
    end

    def expire_time
      self.class.expire_time
    end

    private
    
    attr_reader :logger

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass

        # Set up logger
        @logger = RAILS_DEFAULT_LOGGER
        
        # Specify default extra fields and skipped fields
        @skipped_fields = [ :id, :created_at, :updated_at ]
        @extra_fields = [ ]
    
        # Set up fields fetched from retain
        @retain_fields = db_fields - @skipped_fields + @extra_fields

        # Define getter methods for each field
        db_fields.each do |name|
          eval("def  #{name}
                  logger.debug(\"CMB: #{name} called as field for <\#{self.class}:\#{self.object_id}>\")
                  unless cache_valid? && (temp = cached.#{name})
                    call_load
                    temp = cached.#{name}
                  end
                  return temp
                end", nil, __FILE__, __LINE__)
        end

        # Define getter methods for each association
        db_associations.each do |name|
          eval("def #{name}
                  logger.debug(\"CMB: #{name} called as association for <\#{self.class}:\#{self.object_id}>\")
                  unless cache_valid? && (temp = @cached.#{name})
                    call_load
                    temp = @cached.#{name}
                  end
                  # dump_me(temp)
                  # m = temp.class.instance_method(:wrap_with_combined)
                  # m.bind(temp).call
                  logger.debug(\"CMB: temp.ancestors = \#{temp.class.ancestors.inspect}\")
                  logger.debug(\"CMB: funky.ancestors = \#{(class << temp; self; end).ancestors.inspect}\")
                  temp.wrap_with_combined
                end", nil, __FILE__, __LINE__)
        end

        def dump_me(obj)
          logger.debug("DMP: 0 obj.inspect=#{obj.inspect}")
          klass = obj.class
          return if klass.nil?
          logger.debug("DMP: 1 class=#{klass} name=#{klass.name} methods=#{klass.instance_methods(false).inspect}")
          klass = klass.superclass
          return if klass.nil?
          logger.debug("DMP: 2 class=#{klass} name=#{klass.name} methods=#{klass.instance_methods(false).inspect}")
          klass = klass.superclass
          return if klass.nil?
          logger.debug("DMP: 3 class=#{klass} name=#{klass.name} methods=#{klass.instance_methods(false).inspect}")
          klass = klass.superclass
          return if klass.nil?
          logger.debug("DMP: 4 class=#{klass} name=#{klass.name} methods=#{klass.instance_methods(false).inspect}")
          klass = klass.superclass
          return if klass.nil?
          logger.debug("DMP: 5 class=#{klass} name=#{klass.name} methods=#{klass.instance_methods(false).inspect}")
        end
      }
    end

    def call_load
      logger.debug("CMB: call_load for <#{self.class}:#{self.object_id}>")
      load
      @invalid_cache = false
    end
    
    def cache_valid?
      # If we are not cached at all, then cache is invalid
      if (updated_at = @cached.updated_at).nil?
        logger.debug("CMB: cache_valid?: return false: updated_at is nil")
        return false
      end
      
      # If data type says cache never expires then we are good to go
      if (expire = expire_time) == :never
        logger.debug("CMB: cache_valid?: return true: expire set to :never")
        return true
      end
      
      # If item has been explicitly marked to be re-fetched
      if @invalid_cache
        logger.debug("CMB: cache_valid?: return false: invalid_cache set")
        return false
      end
      
      # else, return if cache time has expired or not
      sum = (updated_at + expire)
      now = Time.now
      r = sum > Time.now
      logger.debug("CMB: cache_valid?: updated_at:#{updated_at}, expire:#{expire}, sum:#{updated_at + expire}, now:#{Time.now}, r:#{r}")
      r
    end
  end
end
