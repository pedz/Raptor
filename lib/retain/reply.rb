
require 'retain/utils'
#
# The Fields class I think is going to be just a bunch of utility
# methods, two for each retain data element.  Given a name like
# "signon", it will create a signon= (writer) and a signon (reader)
# method.  Generally, the write will be used to create a request while
# the reader will be used to pull data out of the replys.  They are
# not going to work together (yet).  But I want the definitions of the
# fields in one place.
#
module Retain
  class Reply
    class Field
      def initialize
        @fields = []
      end

      # Add field +num+ that contains +data+
      # If this is the first +data+ item at index +num+, then +@reply_fields+
      # at +num+ is set to the +data+.  Otherwise, +@reply_fields+ at +num+ is
      # set to an array and +data+ is appeneded to the array.
      def add_field(num, data)
        RAILS_DEFAULT_LOGGER.debug("adding #{num} of #{data.class}")
        if @fields[num].is_a?(Array)
          @fields[num] << data
        elsif @fields[num].nil?
          @fields[num] = data
        else
          old = @fields[num]
          @fields[num] = Array.new
          @fields[num] << old << data
        end
      end
      
      def [](index)
        @fields[index]
      end
      
      Fields::FIELD_DEFINITIONS.each_pair do |k, v|
        index, convert = v
        if convert
          c_in_str = ".upcase.ebcdic"
          c_out_str = ".ascii"
        else
          c_in_str = ""
          c_out_str = ""
        end
        
        eval <<-EOF
          def #{k}
            @fields[#{index}]#{c_out_str}
          end
        EOF
      end
    end
    
    attr_reader :fields, :header, :rc
    
    def initialize(s)
      @header = s[0...128]
      @rc = @header[8...12].net2int
      @fields = scan(s[128...s.length])
    end

    # Scan string s and return an array of structures.  The structures
    # will be a two element structure of element number and the raw
    # data.
    def scan(s)
      r = Field.new
      until s.nil?
        len = s[0...2].net2short
        ele = s[2...4].net2short
        tpe = s[4...6].net2short
        dat = s[6...len]
        if s.length > len
          s = s[len...s.length]
        else
          s = nil
        end
        case ele
        when Fields::DE32
          dat = scan(dat)
        when Fields::CALL_SEARCH_RESULT
          r.add_field(Fields::IRIS, dat[0...12])
          r.add_field(Fields::CALL_SEARCH_RESULT, dat[12...dat.length])
          next
        end
        r.add_field(ele, dat)
      end
      r
    end
  end
end
