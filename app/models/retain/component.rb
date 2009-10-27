# -*- coding: utf-8 -*-

module Retain
  class Component < Base
    set_fetch_sdi Cmpb

    def initialize(options = {})
      logger.debug("Component #{options.inspect}")
      super(options)
    end

    def self.valid?(options)
      true
    end
  end
end
