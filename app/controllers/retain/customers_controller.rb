module Retain
  class CustomersController < RetainController
    def show
      @customer = Combined::Customer.from_param(params[:id], signon_user)
    end
  end
end
