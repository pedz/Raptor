module Combined
  class Registration < Base
    set_expire_time 1.week

    set_db_keys :signon
    add_skipped_fields :signon
    set_db_constants :signon, :software_center, :hardware_center
    add_skipped_fields :software_center_id, :hardware_center_id
    add_extra_fields   :software_center,    :hardware_center
    add_non_retain_associations :queues, :queue_infos
    # These are DB fields used to keep track of when the PSARs were fetched.
    add_skipped_fields :last_day_fetch, :last_all_fetch

    def to_param
      @cached.signon
    end

    def psars
      if @cached.last_all_fetch.nil? || @cached.last_all_fetch < 1.day.ago
        logger.debug("Fetching all PSAR")
        search_hash = {
          :signon2 => @cached.psar_number,
          :psar_start_date => 14.days.ago.strftime("%Y%m%d"),
          :psar_end_date => Time.now.strftime("%Y%m%d")
        }
        Combined::Psar.fetch(search_hash)
        @cached.last_all_fetch = Time.now
        @cached.last_day_fetch = Time.now
        @cached.save!
      elsif @cached.last_day_fetch.nil? || @cached.last_day_fetch < 10.minutes.ago
        logger.debug("Fetching days PSAR")
        search_hash = {
          :signon2 => @cached.psar_number,
          :psar_start_date => Time.now.strftime("%Y%m%d")
        }
        Combined::Psar.fetch(search_hash)
        @cached.last_day_fetch = Time.now
        @cached.save!
      end
      @cached.psars.wrap_with_combined
    end

    private
    
    def load
      logger.debug("CMB: load for #{self.to_s}")
      if @cached.signon.blank?
        @cached.name = ""
        return
      end

      # :group_request is a special case
      group_request = Combined::Registration.retain_fields.map { |field|
        field.to_sym
      }
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
        logger.debug("Can not get to registration")
        raise err unless err.rc == 251
        cache_optins = { }
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
      @cached.updated_at = Time.now
      @cached.update_attributes(cache_options)
    end
  end
end
