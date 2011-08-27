# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class CallsController < JsonCombinedController
      def index
        render :json => ::Combined::Queue.find(params[:queue_id]).calls
      end

      def show
        render :json => ::Combined::Call.find(params[:id])
      end
    end
  end
end
