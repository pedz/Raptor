module Retain
  class RegistrationController < RetainController
    def show
      @reg = Combined::Registration.find_or_initialize_by_signon(params[:id])
    end
  end
end
