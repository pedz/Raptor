# -*- coding: utf-8 -*-

if Module.constants.include? :Footnotes
  Footnotes::Filter.notes -= [:log, :partials]
end
