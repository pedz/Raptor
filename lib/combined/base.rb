module Combined
  class Base
    def initialize(arg)
      super()
      if arg.kind_of? Hash
        @options = arg
      else
        @cached = arg
      end
      @logger = RAILS_DEFAULT_LOGGER
      @logger.debug("CMB: #{self} initialized")
    end

    class << self
      # Create a class instance getters to get an array of Retain
      # fields, all fields in the db class, the skipped fields, the
      # logger, and the subclass.
      
      attr_reader :subclass, :logger
      attr_reader :skipped_fields, :retain_fields, :all_fields

      def add_skipped_fields(*args)
        @skipped_fields += [ *args ]
        @retain_fields  -= [ *args ]
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
        
        # Get the fields for the cached class
        @all_fields = cached_class.columns.map { |r| r.name }

        # Specify default fields to skip
        @skipped_fields = [ "id", "created_at", "updated_at" ]
    
        # Set up fields fetched from retain
        @retain_fields = @all_fields - @skipped_fields

        # Define getter methods for each field
        @all_fields.each do |name|
          eval("def  #{name}
                  load unless cached.#{name} && cache_valid
                  return cached.#{name}
                end", nil, __FILE__, __LINE__)
        end
      }
      # RAILS_DEFAULT_LOGGER.debug("TRACE: #{__FILE__}:#{__LINE__}")
    end

    def cached
      logger.debug("CMB: cached method called self is #{self}")
      @cached ||=
        (temp = self.class.cached_class).find(:first, :conditions => @options) ||
        temp.new(@options)
      logger.debug("CMB: updated_at = #{@cached.updated_at}")
      @cached
    end
  end
end
