module Retain
  class Ssbr < Sdi
    set_fetch_request "SSBR"
    set_required_fields(:apar_number, :signon, :password)
    set_optional_fields(:group_request)

    def initialize(options = {})
      super(options)
    end
  end
end
