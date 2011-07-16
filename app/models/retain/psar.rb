# -*- coding: utf-8 -*-

module Retain
  # A model representing Retain psars.  See Cached::Psars for a list
  # of attributes that are cached.  Uses Retain::Psrr to fetch data
  # from Retain so see it for what can be retrieved from Retain using
  # this model.  Also see Combined::Psar for how the particulars on
  # how the Retain model and the Cached model are joined in this
  # particular instance.
  class Psar < Retain::Base
    set_fetch_sdi Psrr

    def self.range(retain_user_connection_parameters, start_date, stop_date)
      temp = Retain::Psar.new(retain_user_connection_parameters,
                              :psar_start_date => start_date.strftime("%Y%m%d"),
                              :psar_end_date => stop_date.strftime("%Y%m%d"))
      temp.de32s.map do |fields|
        Psar.new :fields => fields
      end
    end

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end

    def to_s
      psar_file_and_symbol
    end

    # Returns true if the psar is a valid psar.  For now, we just
    # return true.  We might do a fetch from retain if we find we need
    # to.
    def self.valid?(retain_user_connection_parameters, options)
      true
    end
  end
end
