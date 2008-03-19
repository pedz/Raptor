module Retain
  class Pmr < Base
    set_fetch_sdi Pmpb

    def initialize(options = {})
      super(options)
    end

    def to_s
      "%s,%s,%s" % [ problem, branch, country ]
    end

    # Returns true if the call is a valid call.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(options)
      true
    end
  end
end
