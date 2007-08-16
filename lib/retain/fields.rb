
require 'retain/utils'

module Retain
  class Fields
    #
    # Field mnemonic names
    #
    IRIS = 290
    CALL_SEARCH_RESULT = 658
    
    FIELD_DEFINITIONS = {     #  Num ebcdic
      "branch"             => [    2,  true ],
      "country"            => [    3,  true ],
      "problem"            => [    4,  true ],
      "customer_number"    => [   11,  true ],
      "queue_name"         => [   27,  true ],
      "de32"               => [   32, false ],
      "center"             => [   41,  true ],
      "iris"               => [  290, false ],
      "call_search_result" => [  658,  true ],
      "h_or_s"             => [ 1135,  true ],
      "signon"             => [ 1236,  true ],
      "password"           => [ 1237,  true ]
    }
    
    def initialize
      @fields = []
    end

    # Add field +num+ that contains +data+
    # If this is the first +data+ item at index +num+, then +@fields+
    # at +num+ is set to the +data+.  Otherwise, +@fields+ at +num+ is
    # set to an array and +data+ is appeneded to the array.
    def << (num, data)
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

    def branch
      @fields[BRANCH]
    end

    def country
      @fields[COUNTRY]
    end

    def problem
      @fields[PROBLEM]
    end

    def customer_number
      @fields[CUSTOMER_NUMBER]
    end

    def de32
      @fields[32]
    end

    def iris
      @fields[IRIS]
    end

    def call_search_result
      @fields[CALL_SEARCH_RESULT]
    end

    def signon
      @fields[SIGNON]
    end

    def password
      @fields[PASSWORD]
    end
  end
end
