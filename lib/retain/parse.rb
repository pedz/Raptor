
require 'retain/utils'

module Retain
  class Parse
    attr_reader :fields
    
    def initialize(s)
      @header = s[0...128]
      @rc = @header[8...12].net2int
      @fields = scan(s[128...s.length])
    end

    # Scan string s and return an array of structures.  The structures
    # will be a two element structure of element number and the raw
    # data.
    def scan(s)
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
          add_field(Fields::IRIS, dat[0...12])
          add_field(Fields::CALL_SEARCH_RESULT, dat[12...dat.length])
          next
        end
        add_field( ele, dat)
      end
      r
    end
  end
end