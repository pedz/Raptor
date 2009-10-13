
require 'retain/utils'
require 'retain/exceptions'
require 'retain/fields'

module Retain
  class SdiReaderError < Exception
    def initialize(base_obj)
      @base_obj = base_obj
      super(base_obj.error_message)
    end

    def sr
      @base_obj.sr
    end
    alias :error_type :sr

    def ex
      @base_obj.ex
    end
    alias :request_error :ex

    def rc
      @base_obj.rc
    end

    def dump_debug
      @base_obj.dump_debug
    end
  end

  class SdiDidNotReadField < Exception
    def initialize(base_obj, field_name)
      @base_obj = base_obj
      @field_name = field_name
    end

    def field_name
      @field_name
    end
  end

  class Base
    cattr_accessor :logger

    ### Class instance methods
    class << self
      attr_reader :subclass

      def set_fetch_sdi(sdi)
        @fetch_sdi = sdi
      end
      alias :fetch_sdi= set_fetch_sdi

      def fetch_sdi
        @fetch_sdi.new
      end
    end

    attr_reader :fields

    ###
    ### instance methods
    ###
    def initialize(options = {})
      super()
      @options = options
      @fields = Fields.new(self.method(:fetch_fields))
      # logger.debug("RTN: initializing #{self.class}")

      # options can have default_fields and fields which are both a
      # list of fields.  We merge in the sequence of :default_fields,
      # then the rest of options, then fields.
      @fields.merge(@options.delete(:default_fields)) if @options.has_key?(:default_fields)
      field_temp = @options.delete(:fields)
      @fields.merge(@options)
      @options = Hash.new
      @fields.merge(field_temp) unless field_temp.nil?
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

    # Note: this overrides the @fields[:error_message]
    def error_message
      @fetch_sdi.error_message
    end

    def sr
      @fetch_sdi.sr
    end
    alias :error_type :sr

    def ex
      @fetch_sdi.ex
    end
    alias :request_error :ex

    def rc
      temp = @fetch_sdi.rc
      logger.error("base error rc = #{temp}")
      temp
    end

    def dump_debug
      @fetch_sdi.dump_debug
    end
    
    def fetch_fields
      # logger.debug("RTN: fetch fields for #{self.class}")
      @fetch_sdi = self.class.fetch_sdi
      @fetch_sdi.sendit(@fields, @options)
      self
    end

    def has_key?(sym)
      @fields.has_key?(sym)
    end

    protected

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)
      
      subclass.class_eval {
        # Rembmer our name
        @subclass = subclass
      }
    end
  end
end
