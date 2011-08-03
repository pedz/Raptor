# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Cached
    class ComponentsController < JsonCachedController
      def index
        json_send(::Cached::Component.find(:all))
      end

      def show
        json_send(::Cached::Component.find(params[:id]))
      end
    end
  end
end
