# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Cached
    class QueuesController < JsonCachedController
      def show
        json_send(::Cached::Queue.find(params[:id]))
      end
    end
  end
end
