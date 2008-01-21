
module Combined
  class AssociationCollection
    include Common
    
    attr_reader :logger
    
    def initialize(object)
      @cached = object
      @logger = RAILS_DEFAULT_LOGGER
    end

    def respond_to?(symbol)
      logger.debug("CMB: respond_to? #{symbol} for association called")
      @cached.respond_to?(symbol)
    end
  end
end
