module Retain
  class Pmcu < Sdi
    
    set_fetch_request "PMCU"
    set_required_fields(:operand, :signon, :password)
    set_optional_fields(:queue_name, :center, :ppg, :h_or_s)

    def initialize(options = {})
      super(options)
    end
  end
end
