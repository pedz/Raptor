
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
      
      @request_string = "SDIYSHD2".user_to_retain + # header element
        0.int2net +               # return code
        2.int2net +               # interface program level
        0x4001.int2net +          # buffer size
        128.int2net +             # length of packet
        0.int2net +               # number of elements
        @options[:request].user_to_retain + # request type
        
        # login and password
        ((Logon.instance.signon + "  ") * 2).user_to_retain +
        0.int2net + 0.int2net +
        
        "I".user_to_retain +             # INBOUND
        "I".user_to_retain +             # INTERNAL
        "I".user_to_retain +             # INTERNAL USE ONLY
        "2".user_to_retain +             # 6 byte headers
        "2".user_to_retain +             # 6 byte headers
        "Y".user_to_retain +             # Always terminate
        " ".user_to_retain +             # space (don't know why)
        " ".user_to_retain +             # space (don't know why)
        0x0025.short2net +      # Coded Character Set Identifier (CCSID)
        (" " * 14).user_to_retain +      # timestamp
        "    ".user_to_retain +          # Id of entry LU (???)
        "    ".user_to_retain +          # Id of dest. LU
        "000" .user_to_retain +          # Country ID
        
        # Billing ID and Extended Billing ID
        ((@options[:billing_id] + "     ")[0..4]).user_to_retain +
        ((@options[:ext_billing_id] + "        ")[0..7]).user_to_retain +
        
        (" " * 8).user_to_retain +       # Server System id
        (" " * 4).user_to_retain +       # Server Application
        0.int2net +             # elapsed time
        0.int2net +             # receive record limit
        (" " * 3).user_to_retain +       # Client source id
        " ".user_to_retain               # Not used
      
      @element_count = 0
    end

    def to_s
      @request_string[PACKET_LENGTH] = @request_string.length.int2net
      @request_string[ELEMENT_COUNT] = @element_count.int2net
      @request_string
    end

    def data_element(id, data)
      @logger.debug("RTN: Adding data_element #{id}='#{data.retain_to_user}' " +
                    "for #{@request}")
      @element_count += 1
      s = 0.short2net + id.short2net + 0.short2net + data
      s[0..1] = s.length.short2net
      @request_string << s
    end
  end
end
