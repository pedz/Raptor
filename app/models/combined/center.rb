module Combined
  class Center < Base
    set_expire_time :never

    def to_param
      @cached.center
    end

    def self.from_param(param)
      options = { :center => param }
      c = find(:first, :conditions => options)
      if c.nil?
        if Retain::Center.check_center(options)
          c = new(options)
        else
          raise CenterNotFound.new(param)
        end
      end
      c
    end

    private

    def load
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")

      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{ center }.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = group_request

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
