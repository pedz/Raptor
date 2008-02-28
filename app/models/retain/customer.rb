module Retain
  class Customer < Base
    set_fetch_sdi Pmcp

    def initialize(options = {})
      super(options)
    end
  end
end
