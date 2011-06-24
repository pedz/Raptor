# -*- coding: utf-8 -*-
module Json
  module Cached
    class RegistrationsController < JsonCachedController
      def index
        json_send(::Cached::Registration.find(:all,
                                              :conditions => {
                                                :apptest => retain_user_connection_parameters.apptest}))
      end

      def show
        json_send(::Cached::Registration.find(params[:id]))
      end
    end
  end
end
