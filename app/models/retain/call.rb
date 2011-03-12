# -*- coding: utf-8 -*-

# = Retain Models
#
# These models represent the "raw" Retain models.  See Retain::Base
# for more information.
#
# Each Retain concept such as Pmr, Call, Queue has a matching Retain
# model which is used to fetch the data if needed from Retain.
#
module Retain
  class Call < Base
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
