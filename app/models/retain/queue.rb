
module Retain
  class Queue < Base
    set_fetch_sdi Scs0

    def initialize(options = {})
      super(options)
    end
    
    def to_s
      ret = queue_name.strip + ',' + center
      if h_or_s? && h_or_s != 'S' && h_or_s != 's'
        ret << h_or_s
      end
      ret
    end
    
    #
    # Returns the list of calls from the de32 field as Retain::Call
    # objects.
    #
    def calls
      temp = de32s
      if temp.length == 1 && temp[0].ppg? == false
        return []
      end
      temp.map do |fields|
        logger.debug("RTN: make a call")
        Call.new :fields => fields
      end
    end
  end
end
