# -*- coding: utf-8 -*-
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
