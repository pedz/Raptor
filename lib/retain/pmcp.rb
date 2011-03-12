# -*- coding: utf-8 -*-

module Retain
  class Pmcp < Sdi
    set_fetch_request "PMCP"
    set_required_fields(:country, :customer_number, :signon, :password)
    set_optional_fields(:group_request)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end
