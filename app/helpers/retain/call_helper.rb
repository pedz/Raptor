module Retain
  module CallHelper
    #
    # line should be a Retain::TextLine.  index is the line number
    # within the PMR
    #
    def show_line(line, index)
      # Retain pages start on two -- go figure.
      span_classes = line.text_type.to_s.gsub('_', '-')
      page = (index / 16)
      if (page * 16) == index
        even_odd = ((page % 2) == 0) ? "even" : "odd"
        div_string = "</div><div class='#{even_odd}'>"
      else
        div_string = nil
      end
      text_line = line.text.gsub(/ /, '&nbsp;')
      render(:partial => "show_line",
             :locals => {
               :text_line => text_line,
               :div_string => div_string,
               :span_classes => span_classes,
               :line => line,
               :index => index,
               :page => page })
    end
  end
end
