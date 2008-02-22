
module Retain
  #
  # This class will implement as a set of objects that will implement
  # each of the SDI calls.  This will act somewhat like a library but
  # I am making them objects so they can contain settings.  Not sure
  # how this is going to work... lets see...
  class Sdi
    cattr_accessor :logger

    ### Class methods to set the class instance variables.
    class << self
      def set_fetch_request(s)
        @fetch_request = s
      end
      alias :fetch_request= :set_fetch_request

      def fetch_request
        @fetch_request
      end

      def set_required_fields(*args)
        @required_fields = args
      end
      alias :required_fields= set_required_fields

      def required_fields
        @required_fields
      end

      def set_optional_fields(*args)
        @optional_fields = args
      end
      alias :optional_fields= set_optional_fields

      def optional_fields
        # sdi subclasses are not required to have optional fields
        @optional_fields || []
      end
    end

    ###
    ### instance methods
    ###
    def initialize(options = {})
      @options = { :request => self.class.fetch_request }.merge(options)
      @fields = Fields.new
      logger.debug("RTN: initializing #{self.class}")
      
      # Look at the default_fields for a list of fields to use as
      # defaults.
      if @options.has_key?(:default_fields)
        @fields.merge(@options.delete(:default_fields))
      end

      # Second precedence is fields specified in options.  We make
      # these fields.
      (self.class.required_fields + self.class.optional_fields).each do |sym|
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
      if false
        logger.debug("RTN: fields = #{fields.to_yaml}")
        logger.debug("RTN: options = #{options.to_yaml}")
      end

      request = Request.new(options)
      self.class.required_fields.each do |sym|
        if true
          logger.debug("RTN: req sym is #{sym} class is #{sym.class}")
        end
        index = Fields.sym_to_index(sym)
        raise "required field #{sym} not present" unless fields.has_key?(sym)
        v = fields[sym]
        if false
          logger.debug("RTN: v.class is #{v.class}")
        end
        request.data_element(index, v.to_s)
      end
      self.class.optional_fields.each do |sym|
        if true
          logger.debug("RTN: opt sym is #{sym} class is #{sym.class}")
        end
        index = Fields.sym_to_index(sym)
        next unless fields.has_key?(sym)
        v = fields[sym]
        if false
          logger.debug("RTN: v.class is #{v.class}")
        end
        request.data_element(index, v.to_s)
      end

      login

      send = request.to_s
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
      if true
        logger.debug("RTN: self is of class #{self.class}")
        logger.debug("RTN: rc should be #{@rc}")
      end

      new_fields = Fields.new
      scan_fields(new_fields, @reply[128...@reply.length])
      req_fields.merge!(new_fields)

      logger.info(new_fields.to_debug)
      unless @rc == 0
        hex_dump("#{options[:request]} request", send)
        logger.info(new_fields.to_debug)
        hex_dump("#{options[:request]} reply", @reply)
      end
    end

    def rc
      @rc
    end
    
    def fields
      @fields
    end

    #
    # Create field getters and setters
    #
    Fields::FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      eval "def #{k};  @fields.#{k}; end", nil, __FILE__, __LINE__
      eval "def #{k}?; @fields.#{k}?; end", nil, __FILE__, __LINE__
      eval "def #{k}=(data); @fields.#{k} = data; end", nil, __FILE__, __LINE__
    end

    private
      
    def connect
      @connection = Connection.new
      @connection.connect
    end

    def login
      #
      # Abort early if the failed flag is already true
      #
      raise Retain::FailedMarkedTrue if Logon.instance.failed

      #
      # Could pull signon and password from options
      #
      first50 = 'SDTC,SDIRETEX' + 
        Logon.instance.signon +
        '  ' +
        Logon.instance.password +
        '00000000   ,IC,000000'
      
      # "encrypt" the password
      send = first50.user_to_retain
      ( 21..28 ).each { |i| send[i] -= 0x3f }
      connect
      @connection.write(send)
      reply = @login_reply = @connection.read(50)
      if  reply
        logger.debug("RTN: reply length is #{reply.length}")
      else
        logger.debug("RTN: nil reply")
      end
      unless reply && reply.length == 50
        hex_dump("first 50 request", send)
        hex_dump("first 50 reply", reply)
        raise Retain::LogonFailed
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
      logger.info("RTN: #{title}")
      line = "     "
      (0..19).each { |b| line << ("%2d " % b) }
      logger.info("RTN: #{line}")
      foo = 0
      until s.nil?
        line = ("%3d:" % foo)
        foo += 20
        l = s.length > 20 ? 20 : s.length
        s[0...l].each_byte { |b| line << (" %02x" % b) }
        logger.info("RTN: #{line}")
        s = s[20...s.length]
      end
    end
  end
end
