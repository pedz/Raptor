module Retain
  class Call < Base
    set_fetch_sdi Pmcb.new

    def initialize(options = {})
      super(options)
    end
    
    #
    # The to_s is called for named routes
    #
    def to_s
      "%s,%s,%s,%s" % [ clean_queue_name , center, h_or_s, ppg ]
    end
    
    def clean_queue_name
      queue_name.gsub(/ +$/, "")
    end
    
    # A convenience method to give back the usual form of
    # problem,branch,country for a call.
    def pbc
      "%s,%s,%s" % [ problem, branch, country ]
    end
  end
end
