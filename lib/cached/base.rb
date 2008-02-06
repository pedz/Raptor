module Cached
  class Base < ActiveRecord::Base
    cattr_accessor :logger

    class << self
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
      logger.debug("CHC: options from retain are #{a.inspect}")
      Hash[ * a ]
    end

    # Fetch or create the DB record from a Retain record  -- probably
    # should not be called "new"
    def self.new_from_retain(retain)
      # Get the fields for the cached class
      # logger.debug("CHC: new #{@subclass} from retain")
      options = options_from_retain(retain)
      find(:first, :conditions => options) || new(options)
    end

    def to_combined
      # logger.debug("CHC: to_combined <#{self.class}:#{self.object_id}>")
      self.class.combined_class.new(self)
    end

    def wrap_with_combined
      # logger.debug("CHC: wrap Cached <#{self.class}:#{self.object_id}>")
      self.class.combined_class.new(self)
    end

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass
      }
    end
  end
end
