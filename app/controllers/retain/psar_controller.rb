# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class PsarController < RetainController
    def show
      # We request PSAR's from Saturday a week ago up to today.
      temp_date = Time.now

      # Move temp_date back to last Saturday
      temp_date -= (temp_date.wday + 1) * (24 * 60 * 60)

      # Now move it back another week
      temp_date -= 7 * 24 * 60 * 60

      # temp_date = Time.mktime(2008, "jan", 1, 0, 0, 0, 0)
      if true
        @psars = Retain::Psar.range(retain_user_connection_parameters, temp_date, Time.now)
        # @psars = Retain::Psar.range(temp_date, temp_date)
      else
        @psars = Retain::Psar.new.de32s.map do |fields|
          Psar.new :fields => fields
        end
      end
    end
  end
end
