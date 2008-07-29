module Combined
  module PsarsHelper
    def chargeable_time(psar)
      display_time(psar.chargeable_time_hex)
    end

    def display_time(t)
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
  end
end
