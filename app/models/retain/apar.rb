# -*- coding: utf-8 -*-

module Retain
  # A model representing Retain APARs.  Currently these are not backed
  # by a Cached model.  Uses Retain::Ssbr to fetch the data.
  class Apar < Retain::Base
    set_fetch_sdi Ssbr

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the apar is a valid apar.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(retain_user_connection_parameters, options)
      true
    end
  end
end
