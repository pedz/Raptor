module Retain
  class Pmpu < Sdi
    set_request "PMPU"
    set_required_fields(:problem, :branch, :country,
                        :signon, :password, :last_alter_timestamp)
    set_optional_fields(:pmr_owner_employee_number)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:last_alter_timestamp)
        @fields[:last_alter_timestamp] = 'NOTMCK'
      end
    end
  end
end