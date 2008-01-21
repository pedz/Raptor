module Retain
  class Call < Base
    set_fetch_sdi Pmcb

    def initialize(options = {})
      super(options)
    end
  end
end
