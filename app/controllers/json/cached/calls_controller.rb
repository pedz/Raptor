# -*- coding: utf-8 -*-
module Json
  module Cached
    class CallsController < Retain::RetainController
      def index
        render :json => ::Cached::Queue.find(params[:queue_id]).calls
      end

      def show
        render :json => ::Cached::Call.find(params[:id])
      end
    end
  end
end
