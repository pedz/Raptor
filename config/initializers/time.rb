# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class Time
  # Minute of Century for Jan. 1st, 2000
  MOC_2000_01_01 = (60 * 24) * 36525
  # Time for Jan. 1st, 2000
  T_2000_01_01 = Time.utc(2000, 01, 01)

  # Create a Time entry given the Minute of the century
  def self.moc(arg)
    T_2000_01_01 + (arg - MOC_2000_01_01).minute
  end

  # Return the minute of the century
  def moc
    MOC_2000_01_01 + ((self - T_2000_01_01) / 60).to_i
  end

  # Returns the start of the previous saturday from today
  def self.previous_saturday
    t = Time.now.utc
    t -= 1.day until t.wday == 6
    t -= 1.week
    Time.gm(t.year, t.month, t.day)
  end
end
