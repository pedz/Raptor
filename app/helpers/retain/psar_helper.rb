module Retain
  module PsarHelper
    def time_format(s)
      i = s.to_i
      hours = i / 10
      dec_hours = i % 10
      "%2d.%1d" % [ hours, dec_hours ]
    end
  end
end
