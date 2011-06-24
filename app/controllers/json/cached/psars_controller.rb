# -*- coding: utf-8 -*-
module Json
  module Cached
    class PsarsController < JsonCachedController
      #
      # This can be called two different ways.  One is a sub resource
      # of a PMR and the other is a sub resource of a registration.
      # We look at the params hash to see what we want to do.
      def index
        if params.has_key? :pmr_id
          json_send(::Cached::Pmr.find(params[:pmr_id]).psars)
        elsif params.has_key? :registration_id
          json_send(::Cached::Registration.find(params[:registration_id]).psars)
        else                    # router should prevent this from happening
          render :json => "Not found", :status => 404
        end
      end

      def show
        json_send(::Cached::Psar.find(params[:id]))
      end
    end
  end
end
