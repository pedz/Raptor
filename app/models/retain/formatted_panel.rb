module Retain
  class FormattedPanel < Base
    set_fetch_sdi Pmfb

    def initialize(options = { })
      super(options)
    end
  end
end
