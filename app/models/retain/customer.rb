module Retain
  class Customer < Base
    set_fetch_sdi Pmcp

    def initialize(options = {})
      super(options)
    end

    # Returns true if the customer is a valid customer.  For now, we
    # just return true.  We might do a fetch from retain if we find we
    # need to.
    def self.valid?(options)
      true
    end
  end
end
