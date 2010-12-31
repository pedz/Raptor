# -*- coding: utf-8 -*-

module Retain
  class Ssbr < Sdi
    set_fetch_request "SSBR"
    set_required_fields(:apar_number, :signon, :password)
    set_optional_fields(:group_request)

    def initialize(params, options = {})
      super(params, options)
    end
  end
end
