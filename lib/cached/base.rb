module Cached
  class Base < ActiveRecord::Base
    cattr_accessor :logger

    class << self
      # list of fields as symbols in this record.
      def db_fields
        (@db_fields ||= [columns.map { |c| c.name.to_sym }])[0]
      end

      # list of associations as symbols in this record.
      def db_associations
        (@db_associations ||= [reflections.values.map{ |r| r.name }])[0]
      end

      def db_keys
        (@db_keys ||= [combined_class.db_keys])[0]
      end

      def keys_only(options)
        r = Hash[ *options.select { |k, v| db_keys.include?(k) }.flatten ]
        logger.debug("CHC: keys_only for #{self} returning: #{r.inspect}")
        r
      end

      # Takes a hash and returns a hash containing only fields in the
      # db record.
      def fields_only(options)
        r = Hash[ *options.select { |k, v| db_fields.include?(k) }.flatten ]
        logger.debug("CHC: fields_only for #{self} returning: #{r.inspect}")
        r
      end

      def once(*ids) # :nodoc:
        for id in ids
          module_eval <<-"end;"
	    alias_method :__#{id.to_i}__, :#{id.to_s}
	    private :__#{id.to_i}__
	    def #{id.to_s}(*args, &block)
	      (@__#{id.to_i}__ ||= [__#{id.to_i}__(*args, &block)])[0]
	    end
	  end;
        end
      end
      private :once
    end

    # Return a hash of options based upon the Retain record
    def self.options_from_retain(retain)
      logger.debug("CHC: options_from_retain retain.fields=#{retain.fields.inspect}")
      logger.debug("CHC: options_from_retain db_fields=#{db_fields.inspect}")
      a = db_fields.select { |sym|
        retain.has_key?(sym)
      }.map { |sym|
        [ sym, retain.send(sym) ]
      }.flatten
      logger.debug("CHC: options from retain are #{a.inspect}")
      Hash[ * a ]
    end

    def self.find_or_new(options)
      find(:first, :conditions => keys_only(options)) || new(options)
    end
    
    # Fetch or create the DB record from a Retain record  -- probably
    # should not be called "new"
    def self.new_from_retain(retain)
      # Get the fields for the cached class
      # logger.debug("CHC: new #{@subclass} from retain")
      options = options_from_retain(retain)
      find_or_new(options)
    end

    # Very similar to find_or_new except calls valid? in the Retain
    # class
    def self.from_options(options)
      logger.debug("CHC: from_options #{self} with #{options.inspect}")
      temp = find(:first, :conditions => keys_only(options))
      if temp.nil? && retain_class.valid?(options)
        temp = new(fields_only(options))
      end
      temp
    end

    def wrap_with_combined
      # logger.debug("CHC: wrap Cached <#{self.class}:#{self.object_id}>")
      @combined ||= self.class.combined_class.new(self)
    end
    alias to_combined wrap_with_combined

    def self.inherited(subclass)
      super(subclass)
      subclass.extend(ClassNameUtils)

      subclass.class_eval {
        # Remember our name
        @subclass = subclass
      }
    end

    # Mark the underlying cached object as dirty
    def mark_as_dirty
      if respond_to?("dirty")
        update_attributes :dirty => true
      end
    end

  end
end
