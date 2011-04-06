
if Module.constants.include? :Footnotes
  Footnotes::Filter.notes -= [:log, :partials]
end
