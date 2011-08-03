# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class Scs0 < Retain::Sdi

    set_fetch_request "SCS0"
    set_required_fields :queue_name, :center, :requested_elements
    set_optional_fields :h_or_s
    
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:requested_elements)
        @fields[:requested_elements] = [
                                        :queue_name,
                                        :center,
                                        :h_or_s,
                                        :ppg,
                                        :problem,
                                        :branch,
                                        :country,
                                        :priority,
                                        :p_s_b,
                                        :comments,
                                        :nls_customer_name,
                                        :cstatus
                                       ]
      end
    end
  end
end
