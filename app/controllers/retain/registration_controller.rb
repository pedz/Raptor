module Retain
  class RegistrationController < RetainController
    def index
      @reg = Retain::Registration.new
      logger.debug("DEBUG: reg #{@reg.queue_name}")
    end
  end
end
