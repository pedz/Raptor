module Combined
  class Registration < Base
    set_expire_time 1.week

    set_db_keys :signon
    add_skipped_fields :signon
    set_db_constants :signon, :software_center, :hardware_center
    add_skipped_fields :software_center_id, :hardware_center_id
    add_extra_fields   :software_center,    :hardware_center
    add_non_retain_associations :queues, :queue_infos


    def to_param
      @cached.signon
    end

    private
    
    def load
      logger.debug("CMB: load for #{self.to_s}")
      if @cached.signon.blank?
        @cached.name = ""
        return
      end

      # :group_request is a special case
      group_request = Combined::Registration.retain_fields.map { |field| field.to_sym }
      retain_options = {
        :group_request => [ group_request ],
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
      else
        cache_options = Cached::Registration.options_from_retain(retain_registration)
        cache_options.delete(:signon)
        logger.debug("CMB: cache_option in registration = #{cache_options.inspect}")
        unless (c = retain_registration.software_center).blank?
          @cached.software_center = first_center = Cached::Center.find_or_new(:center => c)
        end
        unless (d = retain_registration.hardware_center).blank?
          if c == d
            @cached.hardware_center = first_center
          else
            @cached.hardware_center = Cached::Center.find_or_new(:center => d)
          end
        end
      end
      cache_options[:dirty] = false if @cached.respond_to?("dirty")
      @cached.update_attributes(cache_options)
    end
  end
end
