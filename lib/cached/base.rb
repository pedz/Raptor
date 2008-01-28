module Cached
  class Base < ActiveRecord::Base
    class << self
      attr_reader :logger
      @logger = RAILS_DEFAULT_LOGGER

      # list of fields as symbols in this record.
      def db_fields
        @db_fields ||= columns.map { |c| c.name.to_sym }
      end

      # list of associations as symbols in this record.
      def db_associations
        @db_associations ||= reflections.values.map{ |r| r.name }
      end
    end

    # Return a hash of options based upon the Retain record
    def self.options_from_retain(retain)
      # We find the intersection of the db fields and the retain
      # fields and create an options hash with those fields.
      retain_keys = retain.fields.keys
      fields = db_fields & retain_keys
      a = fields.map { |field| [ field, retain.send(field) ] }.flatten
      logger.debug("a is #{a.inspect}")
      Hash[ * a ]
    end

    # Fetch or create the DB record from a Retain record  -- probably
    # should not be called "new"
    def self.new_from_retain(retain)
      # Get the fields for the cached class
      logger.debug("CMB: new #{@subclass} from retain")
      options = options_from_retain(retain)
      find(:first, :conditions => options) || new(options)
    end

    def to_combined
      self.class.combined_class.new(self)
    end

    protected

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass

        # Set up the logger
        @logger = RAILS_DEFAULT_LOGGER
      }
    end
  end
end
