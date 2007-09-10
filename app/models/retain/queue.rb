
module Retain
  class Queue < Base
    set_fetch_sdi Scs0.new

    def initialize(options = {})
      super(options)
    end
    
    def to_s
      ret = queue_name.sub(/ +$/, '') + ',' + center
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
      de32.map do |fields|
        @logger.debug("DEBUG: make a call")
        Call.new :fields => fields
      end
    end

    def decode_center(b1, b2)
      s = (b1 * 256) + b2
      i1 = s / 100;
      i2 = s % 100;
      i3 = i1 - 10;

      ## if it is less than 26, than it's an alphanumeric
      ## center like 13L
      return ("%02d%c" % [ i2, (?A + i3)]).ebcdic if i3 >= 0 && i3 <= 25

      ## Otherwise it is pure numeric
      return ("%03d" % s).ebcdic
    end
  end
end
