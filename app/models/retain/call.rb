module Retain
  class Call < Base
    set_fetch_sdi Pmcb

    def initialize(options = {})
      super(options)
    end
    
    #
    # The to_s is called for named routes
    #
    def to_s
      "%s,%s" % [ full_queue_name, ppg ]
    end
    
    def full_queue_name
      queue_name.gsub(/ +$/, "") + "," + center + "," + h_or_s
    end
    
    def short_queue_name
      full_queue_name.sub(/,[sS]/, '')
    end
  end
end
