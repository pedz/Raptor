# -*- coding: utf-8 -*-
module Json
  module Cached
    class CustomersController < JsonCachedController
      def index
        json_send(::Cached::Customer.find(:all))
      end

      def show
        json_send(::Cached::Customer.find(params[:id]))
      end
    end
  end
end
