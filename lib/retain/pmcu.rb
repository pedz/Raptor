# -*- coding: utf-8 -*-

module Retain
  class Pmcu < Retain::Sdi
    
    set_fetch_request "PMCU"
    set_required_fields(:operand, :signon, :password)
    set_optional_fields(:queue_name, :center, :ppg, :h_or_s)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end
