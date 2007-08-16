
require 'retain/config'
require 'retain/connection'
require 'retain/utils'

module Retain
  class Base
    def initialize
      @connection = Connection.new
      @logged_in = false
      @logger = RAILS_DEFAULT_LOGGER
    end

    def connect
      @connection.connect(Config.symbolize_keys[Node][0])
    end

    # Pass in a RetainUser and tries to log in
    def login(retain_user)
      @login = retain_user.retid.trim(6)
      @password = retain_user.password.trim(8)
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

    # We should already be connected and logged in.  queue is a
    # RetainQueue -- probably should be a hash.
    def cs(queue)
      p = Request.new(:request => "PMCS", :login => @login)
      RAILS_DEFAULT_LOGGER.debug(p.methods.to_yaml)
      p.signon = @login
      p.password = @password
      p.queue_name = queue.queue_name.trim(6)
      p.center = queue.center.trim(3)
      p.h_or_s = "S"

      @connection.write(p)
      f = @connection.read(24)
      len = f[20...24].net2int
      if len > 24
        b = @connection.read(len - 24)
      else
        b = ""
      end
      all = f + b
      # hex_dump("pmcs reply", all)
      Retain::Parse.new(all)
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
