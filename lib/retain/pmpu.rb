# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class Pmpu < Retain::Sdi
    set_fetch_request "PMPU"
    set_required_fields(:problem, :branch, :country,
                        :signon, :password, :last_alter_timestamp)
    set_optional_fields(:pmr_owner_id, :pmr_resolver_id,
                        :queue_name, :center, :ppg, :h_or_s,
                        :next_queue, :next_center, :comment,
                        :problem_crit_sit, :opc)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:last_alter_timestamp)
        @fields[:last_alter_timestamp] = 'NOTMCK'.user_to_retain
      end
    end
  end
end
