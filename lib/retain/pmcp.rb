# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class Pmcp < Retain::Sdi
    set_fetch_request "PMCP"
    set_required_fields(:country, :customer_number, :signon, :password)
    set_optional_fields(:group_request)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end
