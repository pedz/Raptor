module Retain
  class Pmr < Base
    set_fetch_sdi Pmpb.new

    def initialize(options = {})
      super(options)
    end

    def to_s
      "%s,%s,%s" % [ problem, branch, country ]
    end
  end
end
