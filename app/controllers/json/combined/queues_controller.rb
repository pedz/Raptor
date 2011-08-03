# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class QueuesController < Retain::RetainController
      def show
        render :json => ::Combined::Queue.find(params[:id])
      end
    end
  end
end
