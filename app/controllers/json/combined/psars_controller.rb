# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class PsarsController < JsonCombinedController
      #
      # This can be called two different ways.  One is a sub resource
      # of a PMR and the other is a sub resource of a registration.
      # We look at the params hash to see what we want to do.
      def index
        if params.has_key? :pmr_id
          render :json => ::Combined::Pmr.find(params[:pmr_id]).psars
        elsif params.has_key? :registration_id
          render :json => ::Combined::Registration.find(params[:registration_id]).psars
        else                    # router should prevent this from happening
          raise "bad dog"
        end
      end

      def show
        render :json => ::Combined::Psar.find(params[:id])
      end
    end
  end
end
