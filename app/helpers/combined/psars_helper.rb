# -*- coding: utf-8 -*-

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
        a.stop_date <=> b.stop_date
      end.group_by(&:stop_date).group_by { |days_list|
        days_list[1][0].saturday
      }
    end

    def summarize(weeks)
      # logger.debug("PSAR: #{weeks.inspect}")
      weeks.map do |saturday, days|
        week_total = 0
        week_ot_total = 0
        days.map! do |day, psars|
          day_totals = psars.inject([0, 0]) do |totals, psar|
            totals[0] += psar.chargeable_time_hex
            totals[1] += psar.chargeable_time_hex if psar.pmr.hot
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
