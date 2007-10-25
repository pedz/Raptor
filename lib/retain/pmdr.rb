module Retain
  class Pmpb < Sdi
    set_fetch_request "PMDR"
    set_required_fields(:signon, :password)

    def initialize(options = {})
      super(options)
    end
  end
end
