# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class ComponentsController < JsonCombinedController
      def index
        render :json => ::Combined::Component.find(:all)
      end

      def show
        render :json => ::Combined::Component.find(params[:id])
      end
    end
  end
end
