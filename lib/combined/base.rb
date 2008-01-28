module Combined
  class Base

    include Common

    def initialize(arg)
      super()
      if arg.kind_of? Hash
        @options = arg
      else
        @cached = arg
      end
      @logger = RAILS_DEFAULT_LOGGER
      @logger.debug("CMB: <#{self.class}:#{self.object_id}> initialized")
    end

    class << self
      # Create a class instance getters to get an array of Retain
      # fields, all fields in the db class, the skipped fields, the
      # logger, and the subclass.
      
      attr_reader :subclass, :logger

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

    protected
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
                  logger.debug(\"CMB: #{name} called as field\")
                  load unless cached.#{name} && cache_valid
                  return cached.#{name}
                end", nil, __FILE__, __LINE__)
        end

        # Define getter methods for each association
        db_associations.each do |name|
          eval("def  #{name}
                  logger.debug(\"CMB: #{name} called\")
                  load unless cached.#{name} && cache_valid
                  replacement(cached.#{name})
                end", nil, __FILE__, __LINE__)
        end
      }
      # RAILS_DEFAULT_LOGGER.debug("TRACE: #{__FILE__}:#{__LINE__}")
    end

    def cached
      # Can not use to_s in this debugging call -- it creates an infinite loop
      logger.debug("CMB: cached method for <#{self.class}:#{self.object_id}> called.")
      @cached ||=
        (temp = self.class.cached_class).find(:first, :conditions => @options) ||
        temp.new(@options)
      logger.debug("CMB: updated_at = #{@cached.updated_at}")
      @cached
    end

    def cache_valid
      return false if (updated_at = self.cached.updated_at).nil?
      return true if (expire = expire_time) == :never
      (updated_at + expire) > Time.now
    end

    def expire_time
      self.class.expire_time
    end
  end
end
