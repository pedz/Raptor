
require 'retain/utils'

module Retain
  class Base
    def self.set_fetch_sdi(sdi)
      @@fetch = sdi
    end

    ###
    ### instance methods
    ###
    def initialize(options = {})
      @options = options
      @logger = @options.delete(:logger) || RAILS_DEFAULT_LOGGER
      @fields = Fields.new(self.method(:fetch_fields))
      @logger.debug("DEBUG: initializing #{self.class}")

      # options can have default_fields and fields which are both a
      # list of fields.  We merge in the sequence of :default_fields,
      # then the rest of options, then fields.
      @fields.merge(@options.delete(:default_fields)) if @options.has_key?(:default_fields)
      field_temp = @options.delete(:fields)
      @fields.merge(@options)
      @options = Hash.new
      @fields.merge(field_temp) unless field_temp.nil?
    end

    def fetch_fields
      @logger.debug("DEBUG: fetch fields for #{self.class}")
      @@fetch.sendit(@fields, @options)
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
  end
end
