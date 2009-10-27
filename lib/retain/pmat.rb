# -*- coding: utf-8 -*-

module Retain
  class Pmat < Sdi
    set_fetch_request "PMAT"
    set_required_fields(:signon, :password, :problem, :branch, :country)
    set_optional_fields(:addtxt_lines)

    def initialize(options = {})
      super(options)
    end
  end
end
