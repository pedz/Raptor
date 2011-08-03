# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # === Retain Query Queue Model
  #
  # A retain model that is currently used just to explore retain.
  # Uses Retain::Pmqq.  Retain::QqController uses this model.  I
  # believe eventually the data Pmqq provides needs to be exploited.
  class Qq < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmqq
    set_fetch_sdi Pmqq

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Always returns true
    def self.valid?(retain_user_connection_parameters, options)
      true
    end
  end
end
