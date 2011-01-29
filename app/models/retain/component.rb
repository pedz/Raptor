# -*- coding: utf-8 -*-

module Retain
  class Component < Base
    set_fetch_sdi Cmpb

    def initialize(params, options = {})
      logger.debug("Component #{options.inspect}")
      super(params, options)
    end

    def self.valid?(params, options)
      true
    end
  end
end
