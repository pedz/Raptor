module Combined
  class Center < Base
    set_expire_time :never

    set_db_keys :center
    add_skipped_fields :center

    set_db_constants :center

    # Param is center.  Raises CenterNotFound if center is not in
    # database or Retain.
    def self.from_param!(param)
      c = from_param(param)
      if c.nil?
        raise CenterNotFound.new(param)
      end
      c
    end

    def self.from_param(param)
      from_options(:center => param)
    end

    def to_param
      @cached.center
    end

    def to_options
      { :center => center }
    end
    
    private

    def load
      logger.debug("CMB: load for #{self.to_s}")

      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{ center }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = [ group_request ]

      # Setup Retain object
      retain_object = self.class.retain_class.new(options_hash)

      # Touch to cause a fetch
      retain_object.send(group_request[0])

      # Retrieve good stuff
      cache_options = self.class.cached_class.options_from_retain(retain_object)
      @cached.update_attributes(cache_options)
    end
  end
end
