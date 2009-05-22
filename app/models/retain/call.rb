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

    def initialize(options = {})
      super(options)
    end

    # Returns true if the call is a valid call.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(options)
      true
    end
  end
end
