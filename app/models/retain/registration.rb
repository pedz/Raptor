# -*- coding: utf-8 -*-

module Retain
  class Registration < Base
    set_fetch_sdi Pmdr

    def initialize(options = {})
      super(options)
    end

    # Returns true if the registration is a valid registration.  For
    # now, we just return true.  We might do a fetch from retain if we
    # find we need to.
    def self.valid?(options)
      new_options = {
        :secondary_login => options[:secondary_login],
        :group_request => [[ :name ]]
      }
      registration = new(new_options)
      begin
        name = registration.name
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
