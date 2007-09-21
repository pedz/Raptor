module Retain
  class PsarController < RetainController
    def index
      # We request PSAR's from Saturday a week ago up to today.
      temp_date = Time.now

      # Move temp_date back to last Saturday
      temp_date -= (temp_date.wday + 1) * (24 * 60 * 60)

      # Now move it back another week
      temp_date -= 7 * 46 * 60 * 60

      @psars = Retain::Psar.range(temp_date, Time.now)
    end
  end
end
