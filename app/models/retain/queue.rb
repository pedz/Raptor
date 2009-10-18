
module Retain
  class Queue < Base
    set_fetch_sdi Pmcs

    def initialize(options = {})
      super(options)
    end

    # Returns true if the queue is a valid queue.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(options)
      # short circuit asking if queue_name or center is blank
      return false if options[:queue_name].blank? || options[:center].blank?
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
      return [] if hit_count == 0
      local_h_or_s = h_or_s
      de32s.map do |fields|
        temp = fields.call_search_result
        options = { 
          :center => decode_center(temp[0 ... 2]),
          :queue_name => temp[2 ... 8].retain_to_user.strip,
          :h_or_s => local_h_or_s,
          :ppg => "%x" % (temp[10].ord * 256 + temp[11].ord),
          :p_s_b => fields.p_s_b,
          :system_down => fields.system_down,
          :call_search_result => temp
        }
        # logger.debug("RTN: raw iris is #{temp[0 ... 12]}")
        # logger.debug("RTN: make a call options: #{options.inspect}")
        Call.new options
      end
    end

    private

    def decode_center(v)
      s = v.ret2ushort
      i1 = s / 100;
      i2 = s % 100;
      i3 = i1 - 10;

      ## if it is less than 26, than it's an alphanumeric
      ## center like 13L
      return ("%02d%c" % [ i2, (?A + i3)]) if i3 >= 0 && i3 <= 25

      ## Otherwise it is pure numeric
      return ("%03d" % s)
    end


  end
end
