# -*- coding: utf-8 -*-

module Retain
  # A model representing Retain registrations.  See
  # Cached::Registrations for a list of attributes that are cached.
  # Uses Retain::Pmdr to fetch data from Retain so see it for what can
  # be retrieved from Retain using this model.  Also see
  # Combined::Registration for how the particulars on how the Retain
  # model and the Cached model are joined in this particular instance.
  class Registration < Base
    set_fetch_sdi Pmdr

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the registration is a valid registration.  For
    # now, we just return true.  We might do a fetch from retain if we
    # find we need to.
    def self.valid?(retain_user_connection_parameters, options)
      new_options = {
        :secondary_login => options[:secondary_login],
        :group_request => [[ :name ]]
      }
      registration = new(retain_user_connection_parameters, new_options)
      begin
        name = registration.name
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
