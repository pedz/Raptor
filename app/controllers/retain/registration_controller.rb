module Retain
  class RegistrationController < RetainController
    def show
      options = { :secondary_login => params[:id] }
      @reg = Retain::Registration.new(options)
      logger.debug("DEBUG: reg #{@reg.queue_name}")
    end
  end
end
