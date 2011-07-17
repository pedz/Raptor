# -*- coding: utf-8 -*-

module Retain
  # === Retain Formatted Panel Model
  #
  # Not fully flushed out or used yet but this will be used for the
  # "formatted" panels in retain (FA and FI)
  class FormattedPanel < Retain::Base
    ##
    # :attr: fetch_sdi
    # Set to Retain::Pmfb
    set_fetch_sdi Pmfb

    # retain_user_connection_parameters and options are passed up to
    # Retain::Base.initialize
    def initialize(retain_user_connection_parameters, options = { })
      super(retain_user_connection_parameters, options)
    end
  end
end
