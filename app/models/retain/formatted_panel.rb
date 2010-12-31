# -*- coding: utf-8 -*-

module Retain
  class FormattedPanel < Base
    set_fetch_sdi Pmfb

    def initialize(params, options = { })
      super(params, options)
    end
  end
end
