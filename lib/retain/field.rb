module Retain
  #
  # A data element will be stored in a Field.  Fields will be a
  # collection of Field's.  The value of a Field will usually be a
  # string but it can also be a Fields
  #
  # Stored with the field is the width it should be and how to convert
  # it.  The field is always stored in the format that Retain needs
  # (what I call the raw format).  The convert and width is applied
  # normally during the setting of the field.  An output conversion is
  # applied with the field is read.  There are also methods to store
  # and fetch the raw value of the field.
  #
  # There is also a dirty bit that is not used currently.  A field
  # starts out with the dirty bit false and it is set to true when
  # value= or raw_value= is called.
  #
  class Field
    def initialize(cvt, width, value = nil, raw = false)
      super()
      @cvt = cvt
      @width = width
      if raw
        @value = value
      else
        set_value(value)
      end
      @dirty = false
    end

    #
    # Get the value of the field.  Does output conversion -- no fill
    # done
    #
    def value
      if @value.is_a?(Array)
        @value.map { |line| decode(line) }
      else
        decode(@value)
      end
    end

    #
    # Get the value without output conversion
    #
    def raw_value
      @value
    end
    
    #
    # Set the value with input conversion and fill to width
    #
    def value=(v)
      set_value(v)
      @dirty = true
    end
    
    #
    # Set the raw value without input conversion
    #
    def raw_value=(v)
      @value = v
    end
    
    #
    # Mark field as dirty
    #
    def mark_dirty
      @dirty = true
    end
    
    #
    # Ask if field is dirty
    #
    def dirty?
      @dirty
    end

    # Raw Retain value as a string (a sequence of bytes)
    def to_s
      @value.to_s
    end

    private

    # Decodes a "binary" (HEX(2)) center to ascii
    def decode_center(v)
      s = v.ret2ushort
      i1 = s / 100;
      i2 = s % 100;
      i3 = i1 - 10;

      ## if it is less than 26, than it's an alphanumeric
      ## center like 13L
      return ("%02d%c" % [ i2, (?A + i3)]) if i3 >= 0 && i3 <= 25

      ## Otherwise it is pure numeric
      return ("%03d" % s)
    end

    # Encode an ascii center to the "binary" representation
    def encode_center(v)
      # I think if the last character is a digit, we just encode it as a binary
      return v.to_i.ushort2ret if (?0 .. ?9).member?(v[2])

      # Otherwise, the last character effectively becomes the 100's
      # digit with A => 10 (or 1000 after its multiplied by 100)
      return ((v.upcase[2] - ?A + 10) * 100 + v[0..1].to_i).ushort2ret
    end

    def group_request(fields)
      s = ""
      fields.each do |f|
        if f.is_a?(Symbol)
          f = Fields.sym_to_index(f)
        end
        s += f.ushort2ret
      end
      s
    end

    def set_value(value)
      if value.nil?
        return @value = value
      end
      # :group is a special case.  I can't figure out how to not make
      # it one.  So, if the @cvt is :group, we expect value to be an
      # array.  We look at the first value.  If IT is also an array,
      # when we treat it as an array of :group's.
      if @cvt == :group
        is_array = value.is_a?(Array) && value[0].is_a?(Array)
      else
        is_array = value.is_a? Array
      end
      
      if is_array
        @value = value.map { |line| encode(line) }
      else
        @value = encode(value)
      end
    end
    
    def encode(value)
      if @width.nil? || @width < 0
        width = value.length
      else
        width = @width
      end
      case @cvt
      when :int
        v = ""
        while value > 0
          v << "%c" % (value % 256)
          value /= 256
        end
        v += "\0" * width
        v.reverse[0...width]
      when :psarfs
        # The first 12 bytes are characters that we encode to ebcdic.
        # The last 8 characters are actually four bytes encoded as
        # hex.
        value[0 ... 12].user_to_retain +
          value[12 ... 20].scan(/../).map { |s| s.hex }.pack("cccc")
      when :ebcdic_strip
        value.trim(width).upcase.user_to_retain
      when :upper_ebcdic
        value.trim(width).upcase.user_to_retain
      when :ebcdic_y_or_n
        if value
          'Y'.trim(width).user_to_retain
        else
          'N'.trim(width).user_to_retain
        end
      when :ebcdic
        value.trim(width).user_to_retain
      when :binary_center
        encode_center(value.trim(3))
      when :binary
        value
      when :group
        group_request(value)
      when :number              # space filled number
        ("%#{width}d" % value).user_to_retain
      when :znumber             # zero filled number
        RAILS_DEFAULT_LOGGER.debug("width=#{width}, value=#{value}, value.class=#{value.class}")
        ("%0#{width}d" % value).user_to_retain
      when :short
        value.short2ret
      when :ppg
        h = value.hex
        value = "  "
        value[0] = h / 256
        value[1] = h % 256
        value
      when :nls
        raise "Can no encode nls yet"
      when :nls_text_lines
        raise "Can not encode nls text lines yet"
      when :text_lines
        value.trim(width).user_to_retain
      else
        raise "Unknown version method: #{@cvt}"
      end
    end

    def decode(value)
      case @cvt
      when :int
        RAILS_DEFAULT_LOGGER.debug("XXX #{"%02x %02x" % [ value[0], value[1]]}")
        v = 0; value.each_byte { |b| v = v * 256 + b }; v
      when :psarfs
        # The first 12 bytes are ebcdic characters.  The last four are
        # not so we encode each byte as hex (two bytes each)
        value[0 ... 12].retain_to_user +
          value[12 ... 16].unpack("CCCC").map { |c| "%02x" % c }.join("")
      when :ebcdic_strip
        value.retain_to_user.strip
      when :upper_ebcdic
        value.retain_to_user
      when :ebcdic_y_or_n
        value.retain_to_user == 'Y'
      when :ebcdic
        value.retain_to_user
      when :nls
        ccsid = value[0, 2].ret2ushort
        cs = Ccsid.to_cs(ccsid)
        # This seems to be the fastest way to trim off two bytes from
        # the front of a string.  The 10^9 is roughly MAXINT.
        value[2, 1000000000].retain_to_user(cs)
      when :binary_center
        decode_center(value)
      when :group
        value.unpack("n*").map { |index| Fields.index_to_sym(index) }
      when :binary
        value
      when :short
        value.ret2short
      when :nls_text_lines
        TextLine.new(value[2, 1000000000], value[0, 2].ret2ushort)
      when :text_lines
        TextLine.new(value, 37)
      when :number
        value.retain_to_user.to_i
      when :znumber
        value.retain_to_user.to_i
      when :ppg
        "%x" % (value[0] * 256 + value[1])
      end
    end

    def icvt(how)
    end
  end
end
