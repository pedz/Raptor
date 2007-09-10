
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
      get_value
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

    #
    # This is the raw value as a string
    #
    def to_s
      if @value.is_a?(Array)
        group_request(@value)
      else
        @value.to_s
      end
    end

    private

    def group_request(fields)
      s = ""
      fields.each do |f|
        if f.is_a?(Symbol)
          f = Fields.sym_to_index(f)
        end
        s += f.short2net
      end
      s
    end

    def set_value(value)
      if value.nil?
        return @value = value
      end
      if value.is_a?(Array)
        @value = value.map { |line| encode(line) }
      else
        @value = encode(value)
      end
    end
    
    def get_value
      if @value.is_a?(Array)
        @value.map { |line| decode(line) }
      else
        decode(@value)
      end
    end

    def encode(value)
      if @width && @width > 0
        value = value.trim(@width)
      end
      case @cvt
      when :upper_ebcdic then value.upcase.ebcdic
      when :ebcdic then value.ebcdic
      when :nls then value.ebcdic
      when :binary then value
      when :ppg
        h = value.hex
        value = "  "
        value[0] = h / 256
        value[1] = h % 256
        value
      else @logger.debug("DEBUG: @cvt is #{@cvt}")
      end
    end

    def decode(value)
      case @cvt
      when :upper_ebcdic then value.ascii
      when :ebcdic then value.ascii
      when :nls then value.ascii[2...value.length]
      when :binary then value
      when :ppg then
        "%x" % (value[0] * 256 + value[1])
      end
    end

    def icvt(how)
    end
  end
end
