module Retain
  class Queue < Base
    
    set_fetch_request "SCS0"
    set_fetch_required_fields :queue_name, :center, :scs0_group_request
    set_fetch_optional_fields :h_or_s

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:scs0_group_request)
        @fields[:scs0_group_request] = [
                                        :queue_name,
                                        :center,
                                        :h_or_s,
                                        :ppg,
                                        :problem,
                                        :branch,
                                        :country,
                                        :priority,
                                        :p_s_b,
                                        :comments,
                                        :customer_name,
                                        :cstatus
                                       ]
      end
    end

    #
    # Returns the list of calls from the de32 field as Retain::Call
    # objects.
    #
    def calls
      de32.map do |fields|
        puts "make a call"
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
