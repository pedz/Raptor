# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # === Combined Call model
  class Center < Combined::Base
    set_db_keys :center
    set_db_constants :center

    ##
    # words in an array of words whose first element is the name of
    # the center.  Returns an options has that contains a key of
    # :center.
    def self.words_to_options(words)
      { :center => words[0] }
    end

    ##
    # Param is a string with the name of the center.  Raises
    # CenterNotFound if center is not in database or Retain.
    def self.from_param!(param, signon_user = nil)
      c = from_param(param, signon_user)
      if c.nil?
        raise CenterNotFound.new(param)
      end
      c
    end

    ##
    # Takes a param string and returns a Center or nil if the center is invalid.
    def self.from_param(param, signon_user = nil)
      param = signon_user.default_center if param.empty?
      create_from_options(retain_user_connection_parameters, :center => param)
    end

    ##
    # Returns a string with the name of the center.
    def to_param
      @cached.center
    end

    ##
    # Returns a hash with :center as the key and the name of the
    # center as its value.
    def to_options
      { :center => center }
    end

    ##
    # Returns true if time is within the center's prime time shift.
    # Currently, daylight savings time is not considered.  The prime
    # shift is 8 a.m. to 5 p.m. (0800-1700) Monday through Friday.
    # time is assumed to be a DateTime object (or something that acts
    # like it).
    def prime_shift(time)
      t = time.new_offset(tz)
       (8 .. 17) === t.hour && (1 .. 5) === t.wday
    end

    ##
    # Returns the Center's Time Zone as a rational fraction of a day
    def tz
      minutes_from_gmt.to_r / (24 * 60)
    end
    once :tz
    
    private

    ##
    # load (fetch) the Center from Retain and save it into the
    # database.
    def load
      # logger.debug("CMB: load for #{self.to_param}")
      if center == "000"
        @cached.update_attributes(:software_center_mnemonic => "XXX",
                                  :center_daylight_time_flag => false,
                                  :delay_to_time => 0,
                                  :minutes_from_gmt => 0)
        
        return
      end

      # Pull the fields we need from the cached record into an options_hash
      options_hash = Hash[ *%w{ center }.map { |field|
                             [ field.to_sym, @cached.attributes[field] ] }.flatten ]

      # :group_request is a special case
      group_request = self.class.combined_class.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = [ group_request ]

      # Setup Retain object
      retain_object = self.class.retain_class.new(retain_user_connection_parameters, options_hash)

      # Touch to cause a fetch
      retain_object.send(group_request[0])

      # Update call record
      options = self.class.cached_class.options_from_retain(retain_object)
      options[:dirty] = false if @cached.respond_to?("dirty")
      @cached.updated_at = Time.now
      @cached.update_attributes(options)
    end
  end
end
