
require 'retain/utils'

module Retain
  DataElement = Struct.new(:number, :data)
  
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
      r = Fields.new
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
        when 32
          dat = scan(dat)
        when Fields::CALL_SEARCH_RESULT
          r.<<(Fields::IRIS, dat[0...12])
          r.<<(Fields::CALL_SEARCH_RESULT, dat[12...dat.length])
          next
        end
        r.<<( ele, dat)
      end
      r
    end
  end
end
