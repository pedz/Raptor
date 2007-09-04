
require 'retain/utils'

module Retain
  class Base
    ###
    ### Class methods
    ###
    @@fetch_optional_fields = []
    
    #
    # Set the retain call to fetch the record
    #
    def self.set_fetch_request(s)
      @@fetch_request = s
    end
    
    #
    # Set required fields for the fetch
    #
    def self.set_fetch_required_fields(*args)
      @@fetch_required_fields = args
    end
    
    #
    # Set optional fields for fetch
    #
    def self.set_fetch_optional_fields(*args)
      @@fetch_optional_fields = args
    end
    
    ###
    ### instance methods
    ###
    
    def initialize(options = {})
      puts "initializing #{self.class}"
      @options = options
      @logger = @options[:logger] || RAILS_DEFAULT_LOGGER
      @fields = Fields.new(self.method(:fetch_fields))

      (@@fetch_required_fields + @@fetch_optional_fields).each do |sym|
        case sym
        when :signon
          puts "add required or optional field field #{sym}"
          self.signon = @options[:signon] || Logon.instance.signon
        when :password
          puts "add required or optional field field #{sym}"
          self.password = @options[:password] || Logon.instance.password
        else
          if @options.has_key?(sym)
            puts "add required or optional field field #{sym}"
            @fields[sym] = @options[sym]
          end
        end
      end
      
      if @options.has_key?(:default_fields)
        fields = @options.delete(:fields)
        fields.each_pair do |k, v|
          puts "add default field #{k}"
          @fields[k] = v
        end
      end

      if @options.has_key?(:fields)
        fields = @options.delete(:fields)
        fields.each_pair do |k, v|
          puts "add field field #{k}:'#{v}'"
          @fields[k] = v
        end
      end
    end

    def fetch_fields
      #
      # Over time, this will all go away and be set up as instance
      # variables or those magical class variables.
      #
      sendit :request => @@fetch_request
      # @fields = @temp.fields
    end

    #
    # Create field getters and setters
    #
    Fields::FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      eval "def #{k}; @fields.#{k}; end", nil, __FILE__, __LINE__
      eval "def #{k}=(data); @fields.#{k} = data; end", nil, __FILE__, __LINE__
    end

    def connect
      @connection = Connection.new
      @connection.connect
    end

    def login(options = {})
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
      hex_dump("first 50", send)
      connect
      @connection.write(send)
      reply = @login_reply = @connection.read(50)
      puts "reply length is #{reply.length}"
      @logger.debug("reply length: #{reply.length}")
      if reply.length == 50
        # Can add more for things like password date, etc
        true
      else
        false
      end
    end

    def sendit(send_options)
      options = @options.merge(send_options)
      raise "Login Failed" unless login(send_options)

      p = Request.new(send_options)
      @@fetch_required_fields.each do |sym|
        puts "sym is #{sym}"
        index = Fields.sym_to_index(sym)
        raise "required field #{sym} not present" unless @fields.has_key?(sym)
        v = @fields[sym]
        puts "v.class is #{v.class}"
        p.data_element(index, v.to_s)
      end

      send = p.to_s
      hex_dump("#{send_options[:request]} request", send)
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
      hex_dump("#{send_options[:request]} reply", @reply)
      @header = @reply[0...128]
      @rc = @header[8...12].net2int
      puts "self is of class #{self.class}"
      puts "rc should be #{@rc}"
      scan_fields(@fields, @reply[128...@reply.length])
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
