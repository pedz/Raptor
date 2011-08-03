# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Cached
    class RegistrationsController < JsonCachedController
      def index
        json_send(::Cached::Registration.find(:all,
                                              :conditions => {
                                                :apptest => retain_user_connection_parameters.apptest
                                              }))
      end

      def show
        id = params[:id]
        if id.length == 6
          temp = ::Cached::Registration.find_by_signon(id)
        else
          temp = ::Cached::Registration.find(id)
        end
        options = { }
        unless temp.name.nil?
          options[:expires_in] = 1.day
        end
        json_send(temp, options)
      end
    end
  end
end
