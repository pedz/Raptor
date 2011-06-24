# -*- coding: utf-8 -*-
module Json
  module Cached
    class CallsController < JsonCachedController
      def index
        if params.has_key? :queue_id
          json_send(::Cached::Queue.find(params[:queue_id]).calls)
        elsif params.has_key? :pmr_id
          json_send(::Cached::Pmr.find(params[:pmr_id]).calls)
        else
          render :json => "Page not found", :status => 404
        end
      end

      def show
        json_send(::Cached::Call.find(params[:id]))
      end
    end
  end
end
