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
        a.psar_activity_date <=> b.psar_activity_date
      end.group_by(&:stop_date).group_by { |days_list|
        days_list[1][0].saturday
      }
    end

    def summarize(weeks)
      weeks.map do |saturday, days|
        week_total = 0
        days.map! do |day, psars|
          day_total = psars.inject(0) do |total, psar|
            total += psar.chargeable_time_hex
          end
          week_total += day_total
          [day, psars, day_total]
        end
        [saturday, days, week_total]
      end
    end
  end
end
