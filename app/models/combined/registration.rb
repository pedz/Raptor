module Combined
  class Registration < Base
    add_skipped_fields :signon
    set_expire_time :never

    def to_param
      @cached.signon
    end

    def self.default_user
      find_or_initialize_by_signon(Retain::Logon.instance.signon)
    end
    
    def default_center
      software_center || hardware_center
    end

    def default_h_or_s
      (software_center && 'S') ||
        (hardware_center && 'H') ||
        'S'
    end
    
    private
    
    def load
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")
      cached = self.cached

      # :group_request is a special case
      group_request = Combined::Registration.retain_fields.map { |field| field.to_sym }
      retain_options = {
        :group_request => group_request,
        :secondary_login => cached.signon
      }
      retain_registration = Retain::Registration.new(retain_options)
      # Touch the name to force a fetch
      retain_registration.name
      cache_options = Cached::Registration.options_from_retain(retain_registration)
      cache_options.delete(:sigon)
      logger.debug("CMB: cache_option in registration = #{cache_options.inspect}")
      cached.update_attributes(cache_options)
    end
  end
end
