# -*- coding: utf-8 -*-

module Retain
  class FormattedPanel < Base
    set_fetch_sdi Pmfb

    def initialize(retain_user_connection_parameters, options = { })
      super(retain_user_connection_parameters, options)
    end
  end
end
