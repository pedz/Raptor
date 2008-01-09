module Cached
  class Base < ActiveRecord::Base
    class << self
      attr_reader :logger
      @logger = RAILS_DEFAULT_LOGGER
    end

    # Create the DB record from a Retain record
    def self.new_from_retain(retain)
      # Get the fields for the cached class
      logger.debug("CMB: new #{@subclass} from retain")
      all_fields = cached_class.columns.map { |r| r.name.to_sym }
      fields = all_fields & retain.fields.keys
      new_options = Hash[ * fields.map { |field|
                          [ field, retain.send(field) ] }.flatten ]
      new(new_options)
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
