# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class Pmis < Retain::Sdi
    set_fetch_request "PMIS"
    set_required_fields :signon, :password, :group_request

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :isoc_country_name,
                                    :isoc_cntry_name_prt_2,
                                    :country,
                                    :daylight_savings_start_date,
                                    :daylight_savings_stop_date,
                                    :isoc_entitleent_system
                                   ]]
      end
    end
  end
end
