module Retain
  class CustomersController < RetainController
    def show
      @customer = Combined::Customer.from_param(params[:id])
    end
  end
end
