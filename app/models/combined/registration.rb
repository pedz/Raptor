# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # Combined Registration Model
  class Registration < Combined::Base
    set_db_keys :signon
    set_db_constants :signon, :software_center, :hardware_center
    add_skipped_fields :software_center_id, :hardware_center_id
    add_extra_fields   :software_center,    :hardware_center
    # These are DB fields used to keep track of when the PSARs were fetched.
    add_skipped_fields :last_day_fetch, :last_all_fetch

    # Currently for the rest of all of the cached items from Retain,
    # no distinction is made if the object came from production Retain
    # or APPTEST.  This is because I don't think there will be any
    # collisions.  But the registrations are definitely going to
    # collide and it seems easier to keep them separate.  So, the
    # apptest field was added to the database record.  We do not want
    # it in the Retain request and we fill it in just before we save
    # the record from the Retain::Logon#apptest value.
    add_skipped_fields :apptest

    ##
    # The param is the signon (Retain id).
    def to_param
      @cached.signon
    end

    ##
    # Fetches the PSARs for the DR.  All PSARs that are available are
    # fetched once a day and all PSARs for the day are fetched every
    # 10 minutes.
    def psars
      logger.debug("psars for registration #{to_param}")
      unless psar_number.nil?
        if @cached.last_all_fetch.nil? || @cached.last_all_fetch < 1.day.ago
          # logger.debug("Fetching all PSAR")
          search_hash = {
            :psar_number => psar_number, # fetch it if we need to
            # We can only fetch the past 14 days I think but lets try for 21 anyway.
            :psar_start_date => 21.days.ago.strftime("%Y%m%d"),
            :psar_end_date => Time.now.strftime("%Y%m%d")
          }
          Combined::Psar.fetch(retain_user_connection_parameters, search_hash)
          @cached.last_all_fetch = Time.now
          @cached.last_day_fetch = Time.now
          load
          @cached.save!
        elsif @cached.last_day_fetch.nil? || @cached.last_day_fetch < 10.minutes.ago
          # logger.debug("Fetching days PSAR")
          search_hash = {
            :psar_number => @cached.psar_number,
            :psar_start_date => Time.now.strftime("%Y%m%d")
          }
          Combined::Psar.fetch(retain_user_connection_parameters, search_hash)
          @cached.last_day_fetch = Time.now
          @cached.save!
        end
      end
      @cached.psars.wrap_with_combined
    end

    ##
    # If a software center is defined, return it.  Otherwise if a
    # hardware center is defined, return it.  Otherwise return nil.
    def default_center
      if software_center
        software_center
      elsif hardware_center
        hardware_center
      else
        nil
      end
    end
    once :default_center

    ##
    # Similar to default_center.  If a software center is defined,
    # return 'S'.  Otherwise if a hardware center is defined, return
    # 'H'.  Otherwise, return 'S'.
    def default_h_or_s
      if software_center
        'S'
      elsif hardware_center
        'H'
      else
        'S'
      end
    end
    once :default_h_or_s
    
    ##
    # If h_or_s is 'S' returns the software center if it is not null.
    # Else If h_or_s is 'H' returns the hardware center if it is not null.
    # Else return software center if it is not null,
    # Else return hardware center if it is not null,
    # Else return null.
    def center(h_or_s)
      case
        # Simple cases
      when h_or_s == 'S' && software_center
        software_center
      when h_or_s == 'H' && hardware_center
        hardware_center
      else # Odd cases... sorta just guess.
        default_center
      end
    end
    once :center
    
    ##
    # Registration Time Zone as a rational fraction of a day
    def tz
      time_zone_adjustment.to_r / (24 * 60)
    end
    once :tz

    private
    
    ##
    # Fetch (load) the registration from Retain.
    def load
      # logger.debug("CMB: load for #{self.to_param}")
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
      retain_registration = Retain::Registration.new(retain_user_connection_parameters, retain_options)

      # We can not retrive any registration record.  So, we catch the
      # exception
      begin
        # Touch the name to force a fetch
        retain_registration.name
      rescue Retain::SdiReaderError => err
        # logger.debug("Can not get to registration")

        # SR105EX083 is for records we can't fetch
        # SR105EX093 is for records with a bad center
        ok_err = (err.sr == 105) && [83, 93, 94].include?(err.ex)
        raise err unless ok_err
        cache_options = { name: "Unknown" }
      else
        cache_options = Cached::Registration.options_from_retain(retain_registration)
        cache_options.delete(:signon)
        # logger.debug("CMB: cache_option in registration = #{cache_options.inspect}")
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
      cache_options[:apptest] = retain_user_connection_parameters.apptest
      @cached.updated_at = Time.now
      @cached.update_attributes(cache_options)
    end
  end
end
