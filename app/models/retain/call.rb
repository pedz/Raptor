# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  # === Retain Call Model
  #
  # A model representing Retain calls.  See Cached::Calls for a list
  # of attributes that are cached.
  #
  # Each model specifies a fetch_sdi attribute which points to a
  # Retain class that is used to fetch the data from Retain.  That
  # class will specify which data elements can be in the request and
  # reply (although some things are still not clear to me).
  #
  # Each Retain model sits "under" a Combined model.  Raptor works
  # mostly with Combined models which gives the upper levels of the
  # code (the controllers and views) the ability to pretend Retain is
  # a real database and the fetching of the data from Retain and
  # storing it in the local database all happens magically.
  #
  class Call < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmcb
    set_fetch_sdi Pmcb

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the call is a valid call.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(retain_user_connection_parameters, options)
      new_options = {
        :group_request => [[ :comments ]],
        :queue_name => options[:queue_name],
        :center => options[:center],
        :ppg => options[:ppg],
        :h_or_s => options[:h_or_s]
      }
      call = new(retain_user_connection_parameters, new_options)
      begin
        comments = call.comments
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
