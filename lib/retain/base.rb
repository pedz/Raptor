# -*- coding: utf-8 -*-

require 'retain/utils'
require 'retain/exceptions'
require 'retain/fields'

module Retain
  # Exception which is thrown when an SDI fetch operation returns with
  # an error.
  class SdiReaderError < Exception
    # The base object is passed in.
    def initialize(base_obj)
      @base_obj = base_obj
      super(base_obj.error_message)
    end

    # Returns the "SR" field from an SDI error message.
    def sr
      @base_obj.sr
    end
    alias :error_type :sr

    # Returns the "EX" field from an SDI error message.
    def ex
      @base_obj.ex
    end
    alias :request_error :ex

    # Returns the return code which comes from the header of the SDI
    # reply.
    def rc
      @base_obj.rc
    end

    # Method that can be called to dump good stuff to log file.
    def dump_debug
      @base_obj.dump_debug
    end
  end

  # If we make an SDI request looking for field "foo" and the result
  # does not contain field "foo", this exception is thrown.
  class SdiDidNotReadField < Exception
    # Initialized with the base object and the field we were trying to
    # fetch.
    def initialize(base_obj, field_name)
      @base_obj = base_obj
      @field_name = field_name
    end

    # Return the field name we were trying to read.
    def field_name
      @field_name
    end
  end

  #
  # The base class for a Retain model.  Retain models are what the
  # higher levels of the Rails application uses and implement the
  # Retain higher level concepts such as a Problem, Call, PSAR,
  # Component, etc.
  #
  # Each model specifies which Retain::Sdi object to use to fetch the
  # data via set_fetch_sdi.  The reason for the name was because I
  # thought I would have a fetch sdi and a store sdi but storing data
  # via SDI did not lend itself to that concept.
  #
  # A Retain model, such as Retain::Call, sets its fetch_sdi to a
  # Retain::Sdi object such as Retain::Pmcb.  An element of each model
  # is a Retain::Fields object that can be accessed directly but
  # mostly should not be accessed.  Instead, the SDI data element can
  # be accessed directly.
  #
  # For example, since Retain::Call sets its fetch_sdi to Retain::Pmcb
  # and since Retain::Pmcb specifies that a set of required fields,
  # when the Retain::Call instance is created, a hash of options is
  # passed with each of those elements specified.  In this case, the
  # elements are queue_name, center, ppg, h_or_s.  The signon and
  # password are also required but they are retrieved from the
  # Retain::Logon singleton.  group_request is also required but it
  # has a default.  Also, the code in the Combined::Call model will
  # looked at the fields in the Cached::Call model, add some fields to
  # it via add_extra_fields, remove some fields via the
  # add_skipped_fields, and create the group_request that is needed to
  # fill the database required.  The implication of this is that if a
  # new field is to be cached in the Cached::Call database table, the
  # only thing that is needed is to add that field to the database
  # table and Combined will see this and add it to the group_request
  # field of the Retain::Pmcb call that it creates.
  #
  # The Ruby code can now simply assume that the fields have been
  # populated by accessing, for example, call.branch.  A getter method
  # for each SDI data element is created and accesses @fields.branch
  # (in this example).  The getter in Retain::Fields checks to see if
  # the fetch SDI has been sent yet.  If it has not then it is sent
  # and the data received back, parsed, and stored.  The particular
  # field requested is then returned.  If the SDI has already been
  # sent, then the data should be available and is simply returned.
  #
  class Base
    # Initialized in config/initializers/loggers.rb
    cattr_accessor :logger

    ### Class instance methods
    class << self
      attr_reader :subclass

      # Each Retain::XYZ model will call this to set which SDI call to
      # use to fetch the data.  For example, the Retain::Call model
      # sets this to Retain::Pmcb (Problem Management Call Browse).
      def set_fetch_sdi(sdi)
        @fetch_sdi = sdi
      end
      alias :fetch_sdi= set_fetch_sdi

      # Creates the SDI request type specified by the set_fetch_sdi
      # method.
      def fetch_sdi(retain_user_connection_parameters)
        @fetch_sdi.new(retain_user_connection_parameters)
      end
    end

    # Retain::Fields set of fields this model has.
    attr_reader :fields

    ###
    ### instance methods
    ###
    def initialize(retain_user_connection_parameters, options = {})
      super()
      @retain_user_connection_parameters = retain_user_connection_parameters
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

    def retain_user_connection_parameters
      @retain_user_connection_parameters
    end

    #
    # Create field getters and setters for each of the possible
    # fields.  For example, a getter named "country" is created.  Thus
    # a PMR model named pmr will have pmr.country which will retrieve
    # the value of the "country" data element (DE #3).  This will end
    # up calling @fields.country where @fields is of type
    # Retain::Fields.  Similar code in Fields create getter and setter
    # methods which will trigger a fetch from Retain if the data has
    # not been fetched yet.
    #
    Fields::FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      eval "def #{k};  @fields.#{k}; end", nil, __FILE__, __LINE__
      eval "def #{k}?; @fields.#{k}?; end", nil, __FILE__, __LINE__
      eval "def #{k}=(data); @fields.#{k} = data; end", nil, __FILE__, __LINE__
    end

    # Returns the error_message from the fetch_sdi object.
    #
    # Note: this overrides the @fields[:error_message]
    def error_message
      @fetch_sdi.error_message
    end

    # Returns the "SR" field from the fetch_sdi object.
    def sr
      @fetch_sdi.sr
    end
    alias :error_type :sr

    # Returns the "EX" field from the fetch_sdi object.
    def ex
      @fetch_sdi.ex
    end
    alias :request_error :ex

    # Returns the return code of the SDI call.
    def rc
      @fetch_sdi.rc
    end

    # A nifty way to dump good stuff into the log files.
    def dump_debug
      @fetch_sdi.dump_debug
    end
    
    #
    # This method is passed to the initialize method of
    # Retain::Fields.  It is called when the first getter of an SDI
    # data element is accessed.  fetch_fields then creates the SDI
    # object that has been specified by the set_fetch_sdi class call
    # and then calls the sendit method on it passing in model's fields
    # instance variable as well as any options specified when the
    # instance of the model was created.
    #
    # The model itself is returned.
    #
    def fetch_fields
      # logger.debug("RTN: fetch fields for #{self.class}")
      @fetch_sdi = self.class.fetch_sdi(@retain_user_connection_parameters)
      @fetch_sdi.sendit(@fields, @options)
      self
    end

    # Queries the model's fields to see if the particular data element
    # (e.g. branch) is set.
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
