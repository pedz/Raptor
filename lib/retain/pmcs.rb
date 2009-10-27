# -*- coding: utf-8 -*-

module Retain
  class Pmcs < Sdi

    set_fetch_request "PMCS"
    set_required_fields :queue_name, :center, :signon, :password
    set_optional_fields :h_or_s, :title_format_id

    def initialize(options = { })
      super(options)
      unless @fields.has_key?(:title_format_id)
        @fields[:title_format_id] = "0000"
      end
    end
  end
end
