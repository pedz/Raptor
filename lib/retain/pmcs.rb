# -*- coding: utf-8 -*-

module Retain
  class Pmcs < Retain::Sdi

    set_fetch_request "PMCS"
    set_required_fields :queue_name, :center, :signon, :password
    set_optional_fields :h_or_s, :title_format_id

    def initialize(retain_user_connection_parameters, options = { })
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:title_format_id)
        @fields[:title_format_id] = "0000"
      end
    end
  end
end
