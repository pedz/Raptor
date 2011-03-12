# -*- coding: utf-8 -*-

module Retain
  class Pmat < Sdi
    set_fetch_request "PMAT"
    set_required_fields(:signon, :password, :problem, :branch, :country)
    set_optional_fields(:addtxt_lines)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end
