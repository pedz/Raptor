module Retain
  class RegistrationController < RetainController
    def show
      @reg = Combined::Registration.new :signon => params[:id]
    end
  end
end
