# -*- coding: utf-8 -*-

module Retain
  class Pmcp < Sdi
    set_fetch_request "PMCP"
    set_required_fields(:country, :customer_number, :signon, :password)
    set_optional_fields(:group_request)

    def initialize(options = {})
      super(options)
    end
  end
end
