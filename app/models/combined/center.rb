# -*- coding: utf-8 -*-

module Combined
  class Center < Base
    set_expire_time 1.second

    set_db_keys :center
    add_skipped_fields :center

    set_db_constants :center
    add_non_retain_associations :queues

    # words in an array of words whose first element is the name of
    # the center
    def self.words_to_options(words)
      { :center => words[0] }
    end

    # Param is center.  Raises CenterNotFound if center is not in
    # database or Retain.
    def self.from_param!(param, signon_user = nil)
      c = from_param(param, signon_user)
      if c.nil?
        raise CenterNotFound.new(param)
      end
      c
    end

    def self.from_param(param, signon_user = nil)
      param = signon_user.default_center if param.empty?
      create_from_options(retain_user_connection_parameters, :center => param)
    end

    def to_param
      @cached.center
    end

    def to_options
      { :center => center }
    end
    
    private

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
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]

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
