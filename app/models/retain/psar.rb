# -*- coding: utf-8 -*-

module Retain
  class Psar < Base
    set_fetch_sdi Psrr

    def self.range(params, start_date, stop_date)
      temp = Retain::Psar.new(params,
                              :psar_start_date => start_date.strftime("%Y%m%d"),
                              :psar_end_date => stop_date.strftime("%Y%m%d"))
      temp.de32s.map do |fields|
        Psar.new :fields => fields
      end
    end

    def initialize(params, options = {})
      super(params, options)
    end

    def to_s
      psar_file_and_symbol
    end

    # Returns true if the psar is a valid psar.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(params, options)
      true
    end
  end
end
