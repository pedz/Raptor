# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class CentersController < JsonCombinedController
      def index
        render :json => ::Combined::Center.find(:all)
      end

      def show
        render :json => ::Combined::Center.find(params[:id])
      end
    end
  end
end
