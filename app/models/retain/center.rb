module Retain
  class Center < Base
    set_fetch_sdi Pmbc

    def initialize(options = {})
      super(options)
    end
  end
end
