# -*- coding: utf-8 -*-
module Json
  module Cached
    class QueuesController < JsonCachedController
      def show
        json_send(::Cached::Queue.find(params[:id]))
      end
    end
  end
end
