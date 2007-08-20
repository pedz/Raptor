
require 'retain/utils'

module Retain
  class Base
    def initialize(options = {})
      @options = options
      @login = options[:signon].trim(6)
      @password = options[:password].trim(8)
      @logged_in = false
      @logger = RAILS_DEFAULT_LOGGER
    end

    def connect
      @connection = Connection.new
      @connection.connect(Retain::Config.symbolize_keys[RetainConfig::Node][0])
    end

    # Pass in a RetainUser and tries to log in
    def login(options = {})
      first50 = 'SDTC,SDIRETEXuuuuuu  pppppppp00000000   ,IC,000000'.dup
      first50.sub!('uuuuuu', @login)
      first50.sub!('pppppppp', @password)
      # "encrypt" the password
      send = first50.ebcdic
      # hex_dump("first 50", send)
      ( 21..28 ).each { |i| send[i] -= 0x3f }
      # hex_dump("first 50", send)
      connect
      @connection.write(send)
      reply = @login_reply = @connection.read(50)
      @logger.debug("reply length: #{reply.length}")
      if reply.length == 50
        @logged_in = true
        # Can add more for things like password date, etc
        true
      else
        false
      end
    end

    def cs(options)
      p = Request.new(:request => "PMCS", :login => @login)
      p.signon = @login
      p.password = @password
      p.queue_name = options[:queue_name].trim(6)
      p.center = options[:center].trim(3)
      p.h_or_s = options[:h_or_s] || "S"
      sendit(p, options)
    end

    def scs0(options)
      p = Request.new(:request => "SCS0", :login => @login)
      p.signon = @login
      p.queue_name = options[:queue_name].trim(6)
      p.center = options[:center].trim(3)
      p.scs0_group_request = options[:scs0_group_request].map { |ele|
        Fields::FIELD_DEFINITIONS[ele.to_s][0]
      }
      sendit(p, options)
    end
    
    def pmr(options)
      p = Request.new(:request => "PMPB", :login => @login)
      p.signon = @login
      p.password = @password
      if options[:iris]
        p.iris = options[:iris]
      else
        p.problem = options[:problem]
        p.branch = options[:branch]
        p.country = options[:country]
      end
      p.pmpb_group_request = options[:pmpb_group_request].map { |ele|
        Fields::FIELD_DEFINITIONS[ele.to_s][0]
      }
      sendit(p, options)
    end

    def sendit(p, options = {})
      raise "Login Failed" unless login(options)
      send = p.to_s
      # hex_dump("#{p.request} request", send)
      if  @connection.write(send) != send.length
        raise "write to socket failed in sendit"
      end
      f = @connection.read(24)
      raise "read returned nil in sendit" if f.nil?
      raise "short read in sendit" if f.length != 24
      len = f[20...24].net2int
      if len > 24
        b = @connection.read(len - 24)
      else
        b = ""
      end
      all = f + b
      # hex_dump("#{p.request} reply", all)
      Retain::Reply.new(all)
    end
    
    def hex_dump(title, s)
      @logger.debug(title)
      line = "     "
      (0..19).each { |b| line << ("%2d " % b) }
      @logger.debug line
      foo = 0
      until s.nil?
        line = ("%3d:" % foo)
        foo += 20
        l = s.length > 20 ? 20 : s.length
        s[0...l].each_byte { |b| line << (" %02x" % b) }
        @logger.debug line
        s = s[20...s.length]
      end
    end
  end
end
