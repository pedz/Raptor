
module Retain
  class Queue < Base
    set_fetch_sdi Scs0

    def initialize(options = {})
      super(options)
    end

    # Returns true if the call is a valid call.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(options)
      cq = Retain::Cq.new(options)
      begin
        hit_count = cq.hit_count # get hit_count to see if the queue is valid
        return true
      rescue Retain::SdiReaderError => e
        return false
      end
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
