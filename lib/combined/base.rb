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

      def cached_class_name
        # logger.debug("CMB: class name is #{self.to_s}")
        @cached_class_name ||= "Cached::" + self.to_s.sub(/.*::/, "")
      end

      def cached_class
        @cached_class ||= cached_class_name.constantize
      end

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
        logger.debug("CMB: db_keys for #{self} set to #{a.inspect}")
        @db_keys = a
      end
      attr_reader :db_keys
      
      def keys_only(options)
        Hash[ *options.select { |k, v| db_keys.include?(k) }.flatten ]
      end

      def fields_only(options)
        Hash[ *options.select { |k, v| db_fields.include?(k) }.flatten ]
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

    private

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass
        
        # Specify default extra fields and skipped fields
        @skipped_fields = [ :id, :created_at, :updated_at ]
        @extra_fields = [ ]
    
        # Set up fields fetched from retain
        @retain_fields = db_fields - @skipped_fields + @extra_fields

        # Define getter methods for each field
        db_fields.each do |name|
          eval("def  #{name}
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
                  temp.wrap_with_combined
                end", nil, __FILE__, __LINE__)
        end
      }
    end

    def call_load
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
      logger.debug("CMB: cache_valid?: updated_at:#{updated_at}, " +
                   "expire:#{expire}, sum:#{updated_at + expire}, " +
                   "now:#{Time.now}, r:#{r}")
      r
    end
  end
end
