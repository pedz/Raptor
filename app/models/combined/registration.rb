module Combined
  class Registration < Base
    add_skipped_fields :signon
    set_expire_time :never

    def to_param
      @cached.signon
    end

    private
    
    def load
      logger.debug("CMB: load for <#{self.class}:#{self.object_id}> called")
      if @cached.signon.blank?
        @cached.name = ""
        return
      end

      # :group_request is a special case
      group_request = Combined::Registration.retain_fields.map { |field| field.to_sym }
      retain_options = {
        :group_request => group_request,
        :secondary_login => @cached.signon
      }
      retain_registration = Retain::Registration.new(retain_options)

      # We can not retrive any registration record.  So, we catch the
      # exception
      begin
        # Touch the name to force a fetch
        retain_registration.name
      rescue Retain::SdiReaderError => err
        raise err unless err.rc == 251
        # We set software and hardware center to "000" to tell us we
        # don't really know.
        cache_options = {
          :software_center => "000",
          :hardware_center => "000"
        }
      else
        cache_options = Cached::Registration.options_from_retain(retain_registration)
        cache_options.delete(:signon)
        logger.debug("CMB: cache_option in registration = #{cache_options.inspect}")
      end
      @cached.update_attributes(cache_options)
    end
  end
end
