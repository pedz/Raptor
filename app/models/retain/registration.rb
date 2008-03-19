module Retain
  class Registration < Base
    set_fetch_sdi Pmdr

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
