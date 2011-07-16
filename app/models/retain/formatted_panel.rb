# -*- coding: utf-8 -*-

module Retain
  # Not fully flushed out or used yet but this will be used for the
  # "formatted" panels in retain (FA and FI)
  class FormattedPanel < Retain::Base
    set_fetch_sdi Pmfb

    def initialize(retain_user_connection_parameters, options = { })
      super(retain_user_connection_parameters, options)
    end
  end
end
