# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class RegistrationsController < Retain::RetainController
      def index
        render :json => ::Combined::Registration.find(:all,
                                                      :conditions => { :apptest => retain_user_connection_parameters.apptest})
      end

      def show
        render :json => ::Combined::Registration.find(params[:id])
      end
    end
  end
end
