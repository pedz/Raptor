# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # === Retain Center Model
  #
  # A model representing Retain center.  See Cached::Center for a list
  # of attributes that are cached and Combined::Center for how the
  # particulars on how the Retain model and the Cached model are
  # joined in this particular instance.
  class Center < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmbc
    set_fetch_sdi Pmbc

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the center is found in Retain
    def self.valid?(retain_user_connection_parameters, options)
      # short circuit asking if "" is a valid center
      return false if options[:center].blank?
      return false if options[:center] == "000"
      new_options = {
        :center => options[:center],
        :group_request => [[ :software_center_mnemonic ]]
      }
      center = new(retain_user_connection_parameters, new_options)
      begin
        mnemonic = center.software_center_mnemonic
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
