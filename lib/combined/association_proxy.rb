module Combined
  class AssociationProxy
    include Common
    
    def initialize(object)
      @cached = object
      @logger = RAILS_DEFAULT_LOGGER
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

    private
    
    attr_reader :logger

  end
end
