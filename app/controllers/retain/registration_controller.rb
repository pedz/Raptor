module Retain
  class RegistrationController < RetainController
    def show
      @reg = Combined::Registration.new(params[:id])
    end
  end
end
