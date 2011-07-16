# -*- coding: utf-8 -*-
module Retain
  # A model representing Retain calls.  See Cached::Calls for a list
  # of attributes that are cached.  Uses Retain::Pmcb to fetch data
  # from Retain so see it for what can be retrieved from Retain using
  # this model.  Also see Combined::Call for how the particulars on
  # how the Retain model and the Cached model are joined in this
  # particular instance.
  class Call < Retain::Base
    set_fetch_sdi Pmcb

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    # Returns true if the call is a valid call.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(retain_user_connection_parameters, options)
      new_options = {
        :group_request => [[ :comments ]],
        :queue_name => options[:queue_name],
        :center => options[:center],
        :ppg => options[:ppg],
        :h_or_s => options[:h_or_s]
      }
      call = new(retain_user_connection_parameters, new_options)
      begin
        comments = call.comments
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
    end
  end
end
