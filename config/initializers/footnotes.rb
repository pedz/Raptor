# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

if Module.constants.include? :Footnotes
  Footnotes::Filter.notes -= [:log, :partials]
end
