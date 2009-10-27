# -*- coding: utf-8 -*-

module Retain
  class Apar < Base
    set_fetch_sdi Ssbr

    def initialize(options = {})
      super(options)
    end

    # Returns true if the apar is a valid apar.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(options)
      true
    end
  end
end
