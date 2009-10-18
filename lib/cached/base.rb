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
        # logger.debug("CHC: keys_only for #{self} returning: #{r.inspect}")
        r
      end
      
      # Takes a hash and returns a hash containing only fields in the
      # db record.
      def fields_only(options)
        r = Hash[ *options.select { |k, v| db_fields.include?(k) }.flatten ]
        # logger.debug("CHC: fields_only for #{self} returning: #{r.inspect}")
        r
      end
      
      def once(*ids) # :nodoc:
        for id in ids
          clean_id_name = "__UNIQUE__#{id.to_s.sub(/\?/, '')}"
          module_eval <<-mod_end
	    alias_method :#{clean_id_name}, :#{id.to_s}
	    private :#{clean_id_name}
	    def #{id.to_s}(*args, &block)
	      (@#{clean_id_name} ||= [#{clean_id_name}(*args, &block)])[0]
	    end
          mod_end
        end
      end
      private :once

      # Return a hash of options based upon the Retain record
      def options_from_retain(retain)
        # logger.debug("CHC: options_from_retain retain.fields=#{retain.fields.inspect}")
        # logger.debug("CHC: options_from_retain db_fields=#{db_fields.inspect}")
        a = db_fields.select { |sym|
          retain.has_key?(sym)
        }.map { |sym|
          [ sym, retain.send(sym) ]
        }.flatten
        # logger.debug("CHC: options from retain are #{a.inspect}")
        Hash[ * a ]
      end
      
      def find_or_new(options)
        find(:first, :conditions => keys_only(options)) || new(options)
      end
      
      # Fetch or create the DB record from a Retain record
      def find_or_new_from_retain(retain)
        # Get the fields for the cached class
        # logger.debug("CHC: new #{@subclass} from retain")
        options = options_from_retain(retain)
        find_or_new(options)
      end
      
      # Very similar to find_or_new except calls valid? in the Retain
      # class
      def from_options(options)
        # logger.debug("CHC: from_options #{self} with #{options.inspect}")
        temp = find(:first, :conditions => keys_only(options))
        if temp.nil? && retain_class.valid?(options)
          # I changed this July 14, 2008.  It use to be new instead of
          # create.  But, if the queue is valid, lets go ahead and save
          # it in the database.  This makes the cascade of objects more
          # stable (when this object is used to create another object).
          # This might turn out to be a hugh mistake... Lets see...
          #
          # Ok.  That didn't work because when pmr.rb calls this to find
          # the call, the call is saved before the PMR is hooked up.
          # So, we are going to move this back to new and create two new
          # methods create_from_options and new_from_options.
          # new_from_options is just an alias while create will ask if
          # the record is new and save it if it is.
          temp = new(fields_only(options))
        end
        temp
      end
      alias :new_from_options :from_options
    
      # Calls new_from_options which calls valid?
      def create_from_options(options)
        r = new_from_options(options)
        r.save if r && r.new_record?
        r
      end

      def inherited(subclass)
        super(subclass)
        subclass.extend(ClassNameUtils)

        subclass.class_eval {
          # Remember our name
          @subclass = subclass
        }
      end
    end
    
    def wrap_with_combined
      # logger.debug("CHC: wrap Cached <#{self.class}:#{self.object_id}>")
      @combined ||= self.class.combined_class.new(self)
    end
    alias to_combined wrap_with_combined

    # Mark the underlying cached object as dirty
    def mark_as_dirty
      if respond_to?("dirty")
        update_attributes :dirty => true
      end
    end

  end
end
