module Json
  module Cached
    class CustomersController < Retain::RetainController
      def index
        render :json => ::Cached::Customer.find(:all)
      end

      def show
        render :json => ::Cached::Customer.find(params[:id])
      end
    end
  end
end
