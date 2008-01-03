module Combined
  class Registration < Base
    
    # Get the fields for this class
    @all_fields = Cached::Registration.columns.map { |r| r.name }

    # Specify which fields to skip
    @skipped_fields = [ "id", "signon", "created_at", "updated_at" ]

    # create @fields to be the fields we want to fetch from retain
    @fields = []
    @all_fields.each { |name| @fields << name unless @skipped_fields.member?(name) }

    # Define getter methods for each field
    @all_fields.each do |name|
      eval "def #{name}; @cached.#{name}; end", nil, __FILE__, __LINE__
    end
    
    def initialize(login)
      @cached = Cached::Registration.find_by_signon(login)

      # For this class, the cache never expires
      return if @cached

      fields = self.class.send(:instance_variable_get, :@fields)
      group_request = []
      fields.each do |name|
        group_request << name.to_sym
      end
      
      # else we ask retain
      retain_options = { :secondary_login => login, :group_request => group_request }
      retain_registration = Retain::Registration.new(retain_options)
      
      # Create options hash for new db record
      new_options = { }
      fields.each do |name|
        new_options[name] = retain_registration.send(name.to_sym)
      end

      # special case for the signon
      new_options["signon"] = retain_registration.secondary_login

      # create and save db record
      @cached = Cached::Registration.create(new_options)
    end
  end
end
