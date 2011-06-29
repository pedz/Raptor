# -*- coding: utf-8 -*-

module Retain
  # Model representing a Retain Component.  This is not yet backed by
  # a Cached model.  Uses Retain::Cmpb to fetch the data.
  class Component < Base
    set_fetch_sdi Cmpb

    def initialize(retain_user_connection_parameters, options = {})
      # logger.debug("Component #{options.inspect}")
      super(retain_user_connection_parameters, options)
    end

    def self.valid?(retain_user_connection_parameters, options)
      true
    end
  end
end
