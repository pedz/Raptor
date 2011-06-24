# -*- coding: utf-8 -*-
module Json
  module Cached
    class CentersController < JsonCachedController
      def index
        json_send(::Cached::Center.find(:all))
      end

      def show
        json_send(::Cached::Center.find(params[:id]))
      end
    end
  end
end
