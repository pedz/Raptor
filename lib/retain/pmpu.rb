# -*- coding: utf-8 -*-

module Retain
  class Pmpu < Sdi
    set_fetch_request "PMPU"
    set_required_fields(:problem, :branch, :country,
                        :signon, :password, :last_alter_timestamp)
    set_optional_fields(:pmr_owner_id, :pmr_resolver_id,
                        :queue_name, :center, :ppg, :h_or_s,
                        :next_queue, :next_center, :comment,
                        :problem_crit_sit)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:last_alter_timestamp)
        @fields[:last_alter_timestamp] = 'NOTMCK'.user_to_retain
      end
    end
  end
end
