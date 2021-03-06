# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  module PsarsHelper
    def chargeable_time(psar)
      display_time(psar.chargeable_time_hex)
    end

    def display_time(t)
      return "Zero" if t == 0
      ret = ""
      if t > 60
        ret << pluralize(t / 60, "Hour")
        t %= 60
      end
      if t > 0
        ret << " " unless ret.blank?
        ret << pluralize(t, "Minute")
      end
      return ret
    end
    
    def regroup(psars)
      psars.sort do |a, b|
        a.psar_file_and_symbol <=> b.psar_file_and_symbol
      end.group_by(&:psar_day).group_by do |days_list|
        # days_list is of the form (for example):
        # [ 2009-11-16 00:00:00 UTC, [ <Combined::Psar>, <Combined::Psar>, ... <Combined::Psar> ]]
        days_list[1][0].saturday
      end
    end

    def summarize(weeks)
      # logger.debug("PSAR: #{weeks}")
      weeks.map do |saturday, days|
        week_total = 0
        week_ot_total = 0
        days.map! do |day, psars|
          day_totals = psars.inject([0, 0]) do |totals, psar|
            totals[0] += psar.chargeable_time_hex
            totals[1] += psar.chargeable_time_hex if psar.hot?
            totals
          end
          week_total += day_totals[0]
          week_ot_total += day_totals[1]
          [day, psars, day_totals[0], day_totals[1]]
        end
        [saturday, days, week_total, week_ot_total]
      end
    end
  end
end
