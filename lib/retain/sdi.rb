
module Retain
  #
  # This class will implement as a set of objects that will implement
  # each of the SDI calls.  This will act somewhat like a library but
  # I am making them objects so they can contain settings.  Not sure
  # how this is going to work... lets see...
  class Sdi
    ###
    ### Class methods
    ###
    @@optional_fields = []
    
    #
    # Set the SDI call
    #
    def self.set_request(s)
      @@request = s
    end
    
    #
    # Set required fields for SDI call
    #
    def self.set_required_fields(*args)
      @@required_fields = args
    end
    
    #
    # Set optional fields for SDI call
    #
    def self.set_optional_fields(*args)
      @@optional_fields = args
    end

    ###
    ### instance methods
    ###
    def initialize(options = {})
      @options = {:request => @@request}.merge(options)
      @logger = @options[:logger] || RAILS_DEFAULT_LOGGER
      @fields = Fields.new
      @logger.debug("DEBUG: initializing #{self.class}")
      
      # Look at the default_fields for a list of fields to use as
      # defaults.
      @fields.merge(@options.delete(:default_fields)) if @options.has_key?(:default_fields)

      # Second precedence is fields specified in options.  We make
      # these fields.
      (@@required_fields + @@optional_fields).each do |sym|
        case sym
        when :signon
          @fields[sym] = @options[sym] || Logon.instance.signon
        when :password
          @fields[sym] = @options[sym] || Logon.instance.password
        else
          @fields[sym] = @options.delete(sym) if @options.has_key?(sym)
        end
      end

      # Look at the fields option for a list of fields to use as
      # initialized fields.  These take highest precedence.
      @fields.merge(@options.delete(:fields)) if @options.has_key?(:fields)
    end

    def sendit(req_fields, send_options = {})
      fields = @fields.merge(req_fields)
      options = @options.merge(send_options)
      @logger.debug("DEBUG: fields = #{fields.to_yaml}")
      @logger.debug("DEBUG: options = #{options.to_yaml}")

      p = Request.new(options)
      @@required_fields.each do |sym|
        @logger.debug("DEBUG: sym is #{sym} class is #{sym.class}")
        index = Fields.sym_to_index(sym)
        raise "required field #{sym} not present" unless fields.has_key?(sym)
        v = fields[sym]
        @logger.debug("DEBUG: v.class is #{v.class}")
        p.data_element(index, v.to_s)
      end
      @@optional_fields.each do |sym|
        @logger.debug("DEBUG: sym is #{sym}")
        index = Fields.sym_to_index(sym)
        next unless fields.has_key?(sym)
        v = fields[sym]
        @logger.debug("DEBUG: v.class is #{v.class}")
        p.data_element(index, v.to_s)
      end

      raise "Login Failed" unless login

      send = p.to_s
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
      @reply = f + b
      @header = @reply[0...128]
      @rc = @header[8...12].net2int
      @logger.debug("DEBUG: self is of class #{self.class}")
      @logger.debug("DEBUG: rc should be #{@rc}")

      new_fields = Fields.new
      scan_fields(new_fields, @reply[128...@reply.length])
      req_fields.merge!(new_fields)

      unless @rc == 0
        hex_dump("#{options[:request]} request", send)
        hex_dump("#{options[:request]} reply", @reply)
        if req_fields.error_message?
          raise req_fields.error_message
        else
          raise Errors[@rc]
        end
      end
    end

    private
      
    def connect
      @connection = Connection.new
      @connection.connect
    end

    def login
      #
      # Could pull signon and password from options
      #
      first50 = 'SDTC,SDIRETEX' + 
        Logon.instance.signon +
        '  ' +
        Logon.instance.password +
        '00000000   ,IC,000000'
      
      # "encrypt" the password
      send = first50.ebcdic
      # hex_dump("first 50", send)
      ( 21..28 ).each { |i| send[i] -= 0x3f }
      # hex_dump("first 50", send)
      connect
      @connection.write(send)
      reply = @login_reply = @connection.read(50)
      @logger.debug("DEBUG: reply length is #{reply.length}")
      @logger.debug("DEBUG: reply length: #{reply.length}")
      if reply.length == 50
        # Can add more for things like password date, etc
        true
      else
        false
      end
    end
    
    def scan_fields(fields, s, six_byte_headers = true)
      de32 = Array.new
      until s.nil?
        len = s[0...2].net2short
        ele = s[2...4].net2short
        if six_byte_headers
          tpe = s[4...6].net2short
          dat = s[6...len]
        else
          dat = s[4...len]
        end
        if s.length > len
          s = s[len...s.length]
        else
          s = nil
        end
        case ele
        when Fields::DE32
          de32 << scan_fields(Fields.new(nil), dat, false)
          next
        end
        fields.add_raw(ele, dat)
      end
      fields[Fields::DE32] = de32 unless de32.empty?
      fields
    end
    
    def hex_dump(title, s)
      @logger.debug("DEBUG: #{title}")
      line = "     "
      (0..19).each { |b| line << ("%2d " % b) }
      @logger.debug("DEBUG: #{line}")
      foo = 0
      until s.nil?
        line = ("%3d:" % foo)
        foo += 20
        l = s.length > 20 ? 20 : s.length
        s[0...l].each_byte { |b| line << (" %02x" % b) }
        @logger.debug("DEBUG: #{line}")
        s = s[20...s.length]
      end
    end
  end
end
