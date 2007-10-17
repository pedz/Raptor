
require 'retain/utils'

module Retain
  class Request
    PACKET_LENGTH = 20...24
    ELEMENT_COUNT = 24...28

    def initialize(options = {})
      # Set up options with valid defaults
      @options = {              # Default options
        :billing_id => "AIX",
        :ext_billing_id => "AIX"
      }.merge(options)
      @logger = @options[:logger] || RAILS_DEFAULT_LOGGER

      # Only used to make debugging easy
      @request = @options[:request]

      @request_string = "SDIYSHD2".ebcdic + # header element
        0.int2net +               # return code
        2.int2net +               # interface program level
        0x4001.int2net +          # buffer size
        128.int2net +             # length of packet
        0.int2net +               # number of elements
        @options[:request].ebcdic + # request type

        # login and password
        ((Logon.instance.signon + "  ") * 2).ebcdic +
        0.int2net + 0.int2net +

        "I".ebcdic +             # INBOUND
        "I".ebcdic +             # INTERNAL
        "I".ebcdic +             # INTERNAL USE ONLY
        "2".ebcdic +             # 6 byte headers
        "2".ebcdic +             # 6 byte headers
        "Y".ebcdic +             # Always terminate
        " ".ebcdic +             # space (don't know why)
        " ".ebcdic +             # space (don't know why)
        0x0025.short2net +      # Coded Character Set Identifier (CCSID)
        (" " * 14).ebcdic +      # timestamp
        "    ".ebcdic +          # Id of entry LU (???)
        "    ".ebcdic +          # Id of dest. LU
        "000" .ebcdic +          # Country ID

        # Billing ID and Extended Billing ID
        ((@options[:billing_id] + "     ")[0..4]).ebcdic +
        ((@options[:ext_billing_id] + "        ")[0..7]).ebcdic +

        (" " * 8).ebcdic +       # Server System id
        (" " * 4).ebcdic +       # Server Application
        0.int2net +             # elapsed time
        0.int2net +             # receive record limit
        (" " * 3).ebcdic +       # Client source id
        " ".ebcdic               # Not used

      @element_count = 0
    end

    def to_s
      @request_string[PACKET_LENGTH] = @request_string.length.int2net
      @request_string[ELEMENT_COUNT] = @element_count.int2net
      @request_string
    end

    def data_element(id, data)
      @logger.debug("DEBUG: Adding data_element #{id}='#{data.ascii}' " +
                    "for #{@request}")
      @element_count += 1
      s = 0.short2net + id.short2net + 0.short2net + data
      s[0..1] = s.length.short2net
      @request_string << s
    end
  end
end
