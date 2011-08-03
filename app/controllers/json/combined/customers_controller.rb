# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class CustomersController < Retain::RetainController
      def index
        render :json => ::Combined::Customer.find(:all)
      end

      def show
        render :json => ::Combined::Customer.find(params[:id])
      end
    end
  end
end
