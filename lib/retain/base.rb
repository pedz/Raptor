
require 'retain/utils'
require 'retain/exceptions'

module Retain
  class Base
    ### Class instance methods
    class << self
      attr_reader :subclass, :logger
      
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
      @logger = @options.delete(:logger) || RAILS_DEFAULT_LOGGER
      @fields = Fields.new(self.method(:fetch_fields))
      @logger.debug("RTN: initializing #{self.class}")

      # options can have default_fields and fields which are both a
      # list of fields.  We merge in the sequence of :default_fields,
      # then the rest of options, then fields.
      @fields.merge(@options.delete(:default_fields)) if @options.has_key?(:default_fields)
      field_temp = @options.delete(:fields)
      @fields.merge(@options)
      @options = Hash.new
      @fields.merge(field_temp) unless field_temp.nil?
    end

    def rc
      @rc
    end

    def fetch_fields
      @logger.debug("RTN: fetch fields for #{self.class}")
      fetch_sdi = self.class.fetch_sdi
      fetch_sdi.sendit(@fields, @options)
      @rc = fetch_sdi.rc
      self
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

    protected

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)
      
      subclass.class_eval {
        # Rembmer our name
        @subclass = subclass

        # Set up Logger
        @logger = RAILS_DEFAULT_LOGGER
      }
    end
  end
end
