# -*- coding: utf-8 -*-

module Retain
  class Qq < Base
    set_fetch_sdi Pmqq

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the queue query is a valid queue query.  For
    # now, we just return true.  We might do a fetch from retain if we
    # find we need to.
    def self.valid?(retain_user_connection_parameters, options)
      true
    end
  end
end
