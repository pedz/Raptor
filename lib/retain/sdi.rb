
module Retain
  #
  # This class will implement as a set of objects that will implement
  # each of the SDI calls.  This will act somewhat like a library but
  # I am making them objects so they can contain settings.  Not sure
  # how this is going to work... lets see...
  class Sdi
    cattr_accessor :logger, :instance_writer => false

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
      super()
      @options = { :request => self.class.fetch_request }.merge(options)
      @fields = Fields.new
      # self.logger.debug("RTN: initializing #{self.class}")
      
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
      @snd_fields = @fields.merge(req_fields)
      options = @options.merge(send_options)
      if false
        RAILS_DEFAULT_LOGGER.debug("class is #{self.class}")
        # logger.debug("RTN: sendit for #{self.class} called")
        # logger.debug("RTN: @snd_fields")
        @snd_fields.dump_fields
        # logger.debug("RTN: options")
        # logger.debug("RTN: #{options.to_yaml}")
      end

      request = Request.new(options)
      self.class.required_fields.each do |sym|
        # if true
        #   logger.debug("RTN: required symbol: #{sym}")
        # end
        raise "required field #{sym} not present" unless @snd_fields.has_key?(sym)
        @snd_fields.add_to_req(request, sym)
      end

      self.class.optional_fields.each do |sym|
        # if true
        #   logger.debug("RTN: optional symbol: #{sym}")
        # end
        next unless @snd_fields.has_key?(sym)
        @snd_fields.add_to_req(request, sym)
      end

      if Retain::NO_SENDIT
        # logger.debug("NO_SENDIT true")
        @rc = 0
        return
      end

      if @snd_fields.has_key? :h_or_s
        h_or_s = @snd_fields.h_or_s
      else
        h_or_s = 'S'
      end
      
      login(h_or_s)

      @snd = request.to_s
      if  @connection.write(@snd) != @snd.length
        raise "write to socket failed in sendit"
      end
      f = @connection.read(24)
      raise "read returned nil in sendit" if f.nil?
      raise "short read in sendit" if f.length != 24
      len = f[20...24].ret2uint
      if len > 24
        b = @connection.read(len - 24)
      else
        b = ""
      end
      @reply = f + b
      # if true
      #   logger.debug("RTN: len is #{len}, reply.length is #{@reply.length}")
      # end
      @header = @reply[0...128]
      @rc = @header[8...12].ret2uint
      # if true
      #   logger.debug("RTN: self is of class #{self.class}")
      #   logger.error("RTN: rc should be #{@rc}")
      # end

      # Set request type before calling scan_fields just in case it
      # has to produce some error logs.
      @request_type = options[:request]
      logger.debug("SDI: #{@request_type}")
      @rcv_fields = scan_fields(Fields.new, @reply[128...@reply.length])

      # dump_debug

      # merge received fields back into base objects fields.
      req_fields.merge!(@rcv_fields)
      @fields.error_message = @rcv_fields.error_message if @rcv_fields.has_key?(:error_message)
      if @rc == 0
        @error_message = nil
      else
        if @rcv_fields.has_key?(:error_message)
          msg = @rcv_fields.error_message
          if msg =~ /I\/O ERR=/
            tmp = @rcv_fields.raw_field(:error_message).raw_value
            if tmp.is_a? Array
              tmp = tmp[0]
            end
            msg = parse_io_err(tmp)
          end
        else
          msg = Errors[@rc] || "Unknown Error"
        end
        @error_message = msg
        logger.error("SDI: #{@request_type}: #{@error_message}")
        if @rc == 703 || @rc == 705
          raise Retain::LogonFailed
        end
      end
    end

    def dump_debug
      logger.error("RTN: request fields:\n#{@snd_fields.to_debug}")
      hex_dump("#{@request_type} request", @snd)
      logger.error("RTN: return fields:\n#{@rcv_fields.to_debug}")
      hex_dump("#{@request_type} reply", @reply)
    end

    # def sendit_with_benchmark(*args)
    #   realtime = Benchmark.realtime{ sendit_without_benchmark(*args) }
    #   controller.increment_retain_time(realtime)
    # end
    # alias_method_chain :sendit, :benchmark

    def sr
      @sr ||= if md = /SR([0-9][0-9][0-9])EX([0-9][0-9][0-9])/.match(@error_message)
                md[1].to_i
              end
    end
    alias :error_type :sr

    def ex
      @ex ||= if @error_message.nil?
                0
              elsif md = /SR([0-9][0-9][0-9])EX([0-9][0-9][0-9])/.match(@error_message)
                md[2].to_i
              else
                self.rc
              end
    end
    alias :request_error :ex

    def error_class
      @error_class ||= case self.ex
                       when 0; :normal
                       when 600 .. 700; :warning
                       else :error
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

    # Note: this overrides @fields[:error_message]
    def error_message
      @error_message
    end

    private

    def parse_io_err(raw_msg)
      "%s%02x%02x%02x%02x%s%d%s%02x%02x%s%02x%02x%s%02x%02x%02x%s" %
        [
         raw_msg[ 0 .. 7].retain_to_user, # I/O ERR=
         raw_msg[ 8],                     # four hex byes
         raw_msg[ 9],                     # 
         raw_msg[10],                     # 
         raw_msg[11],                     # 
         raw_msg[12 .. 42].retain_to_user,#  F/S=20bytes R/C=
         raw_msg[43],                     # decimal return code
         raw_msg[44 .. 49].retain_to_user,#  BDOP=
         raw_msg[50],                     # two bytes in hex
         raw_msg[51],                     #
         raw_msg[52 .. 57].retain_to_user,#  DERR=
         raw_msg[58],                     # CDBM ERR1
         raw_msg[59],                     # CDBM ERR2
         raw_msg[60 .. 65].retain_to_user,#  DEXC=
         raw_msg[66],                     # CDBM EXC1
         raw_msg[67],                     # CDBM EXC2
         raw_msg[68],                     # CDBM EXC3
         raw_msg[69 .. 78].retain_to_user #  SRxxxEXnnn
        ]
    end
      
    def connect(h_or_s)
      @connection = Connection.new(h_or_s)
      @connection.connect
    end

    # From SDI for Dummies appendix E.
    #
    # Ret. Code | Reason | Pass/Fail | Description
    #        16 |     18 |      Fail | Retain database not available for userid
    #           |        |           |   validation
    #        70 |     19 |      Fail | Userid is set to inactive
    #        70 |     20 |      Fail | Userid is being blocked due to
    #           |        |           |   excessive errors
    #        70 |     21 |      Fail | Client IP address being blocked
    #           |        |           |   due to excessive errors
    #        70 |     22 |      Fail | Client IP address blocked for
    #           |        |           |   other error
    #        70 |      2 |      Fail | Password does not match current
    #           |        |           |   database password
    #        70 |      3 | Cond Pass | Password has expired, only
    #           |        |           |   a PMDR change password
    #           |        |           |   permitted
    #        69 |      8 |      Fail | Invalid/Unknown Retain userid
    #         8 |     16 |      Fail | Invalid Eyecatch "SDIRETEX"
    #         8 |     12 |      Fail | Userid blank
    #         8 |      8 |      Fail | Password blank
    #         4 |      n |      Pass | Userid/Password validated,
    #           |        |           |   password will expire in n (1 to
    #           |        |           |   7) days
    #         0 |      n |      Pass | Userid/Password validated,
    #           |        |           |   password will expire in n (8 to
    #           |        |           |   90) days
    def login(h_or_s)
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
      
      @logon_request = first50.user_to_retain
      # "encrypt" the password
      ( 21..28 ).each { |i| @logon_request[i] = (@logon_request[i].ord - 0x3f).chr }
      connect(h_or_s)
      @connection.write(@logon_request)
      @logon_reply = @connection.read(50)
      raise RetainLogonEmpty if @logon_reply.nil?
      raise RetainLogonShort if @logon_reply.length < 35
      # if  @logon_reply
      #   logger.debug("RTN: reply length is #{@logon_reply.length}")
      # else
      #   logger.debug("RTN: nil reply")
      # end
      @logon_return = @logon_reply[24,4].retain_to_user.to_i
      Logon.instance.return_value = @logon_return
      @logon_reason = @logon_reply[28,4].retain_to_user.to_i
      Logon.instance.reason = @logon_reason
      # logger.debug("Logon Return: #{@logon_return}")
      # logger.debug("Logon Reason: #{@logon_reason}")
      unless @logon_reply && @logon_reply.length == 50
        hex_dump("first 50 request", @logon_request)
        hex_dump("first 50 reply", @logon_reply)
        raise Retain::LogonFailed
      end
    end
    
    def scan_fields(fields, s, six_byte_headers = true)
      # logger.debug("RTN: start scan_fields")
      if false
        hex_dump("scan_fields", s)
        orig_len = s.length
      end
      de32 = Array.new
      until s.nil? || s.length == 0
        len = s[0...2].ret2ushort
        ele = s[2...4].ret2ushort
        # if false
        #   logger.debug("scan_fields: offset = #{orig_len - s.length}, len = #{len}, ele = #{ele}")
        # end
        if len == 0
          logger.error("SDI ERROR: len = 0. s.length is #{s.length}")
          hex_dump("#{@request_type} request", @snd)
          hex_dump("#{@request_type} reply", @reply)
          break
        end
        if six_byte_headers
          tpe = s[4...6].ret2ushort
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
          de32 << scan_fields(Fields.new, dat, false)
          next
        end
        fields.add_raw(ele, dat)
      end
      fields[:de32s] = de32 unless de32.empty?
      # logger.debug("RTN: end scan_fields")
      fields
    end
    
    def hex_dump(title, s)
      logger.error("RTN: #{title}")
      line = "     "
      (0..19).each { |b| line << ("%2d " % b) }
      logger.error("RTN: #{line}")
      foo = 0
      until s.nil?
        line = ("%3d:" % foo)
        foo += 20
        l = s.length > 20 ? 20 : s.length
        s[0...l].each_byte { |b| line << (" %02x" % b) }
        logger.error("RTN: #{line}")
        s = s[20...s.length]
      end
    end
  end
end
