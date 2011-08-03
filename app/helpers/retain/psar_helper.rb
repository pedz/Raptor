# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

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
