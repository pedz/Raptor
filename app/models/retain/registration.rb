module Retain
  class Registration < Base
    set_fetch_sdi Pmdr

    def initialize(options = {})
      super(options)
    end
  end
end
