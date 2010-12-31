# -*- coding: utf-8 -*-

module Retain
  class Qq < Base
    set_fetch_sdi Pmqq

    def initialize(params, options = {})
      super(params, options)
    end

    # Returns true if the queue query is a valid queue query.  For
    # now, we just return true.  We might do a fetch from retain if we
    # find we need to.
    def self.valid?(options)
      true
    end
  end
end
