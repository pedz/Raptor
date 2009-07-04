module Retain
  class Pmr < Base
    set_fetch_sdi Pmpb

    def initialize(options = {})
      super(options)
    end

    def to_s
      "%s,%s,%s" % [ problem, branch, country ]
    end

    # Returns true if the pmr is a valid pmr.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(options)
      logger.debug("in PMR valid?")
      pmr = new(options.merge({ :group_request => [[ :comments ]]}))
      begin
        comments = pmr.comments
      rescue Retain::SdiReaderError => e
        if e.sr == 115 && e.ex == 125
          raise Combined::PmrNotFound.new("%s,%s,%s" % [ pmr.problem, pmr.branch, pmr.country ])
        else
          raise e
        end
      end
    end
  end
end
