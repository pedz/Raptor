module Retain
  class Pmcs < Sdi

    set_fetch_request "PMCS"
    set_required_fields :queue_name, :center, :signon, :password
    set_optional_fields :h_or_s

    def initialize(options = { })
      super(options)
    end
  end
end
