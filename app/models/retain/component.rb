# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # === Retain Component Model
  #
  # Model representing a Retain Component.  This is not yet backed by
  # a Cached model.  Uses Retain::Cmpb to fetch the data.
  class Component < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Cmpb
    set_fetch_sdi Cmpb

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = {})
      # logger.debug("Component #{options.inspect}")
      super(retain_user_connection_parameters, options)
    end

    # Currently always returns true.
    def self.valid?(retain_user_connection_parameters, options)
      true
    end
  end
end
