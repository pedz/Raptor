module Retain
  module CallHelper
    def ecpaat_lines(pmr)
      temp_hash = pmr.ecpaat
      temp_lines = []
      Cached::Pmr::ECPAAT_HEADINGS.each { |heading|
        unless (lines = temp_hash[heading]).nil?
          temp_lines << "<span class='ecpaat-heading'>" + heading + ": " + "</span>" +
            lines.shift
          temp_lines += temp_hash[heading]
        end
      }
      temp_lines.join("<br/>\n")
    end
    #
    # line should be a Retain::TextLine.  index is the line number
    # within the PMR
    #
    def show_line(line, index, tz)
      # Retain pages start on two -- go figure.
      span_classes = line.text_type.to_s.gsub('_', '-')
      page = (index / 16)
      if (page * 16) == index
        even_odd = ((page % 2) == 0) ? "even" : "odd"
        div_string = "</div><div class='#{even_odd}'>"
        float_string = "<div class='#{even_odd}-float'>#{page + 2}</div>"
        div_string += float_string
      else
        div_string = nil
      end
      if line.text_type == :signature
        sig_line = Retain::SignatureLine.new(line.text)
        text_line = sig_line.to_s(tz).gsub(/ /, '&nbsp;')
      else
        text_line = line.text.gsub(/ /, '&nbsp;')
      end
      render(:partial => "show_line",
             :locals => {
               :text_line => text_line,
               :div_string => div_string,
               :span_classes => span_classes,
               :line => line,
               :index => index,
               :page => page })
    end

    def display_update_button(binding)
      span binding, :class => 'call-update-span' do |binding|
        concat(button("Update", "$(\"call_update_span\").toggleCallUpdateForm();"), binding)
      end
    end

    def display_update_form(binding, call)
      span binding, :id => 'call_update_span', :class => 'call-update-container' do |binding|
        call_update = CallUpdate.new(call)
        concat(render(:partial => 'shared/retain/call_update',
                      :locals => { :call_update => call_update }),
               binding)
      end
    end

    def display_pmr_owner(binding, call)
      td binding, :class => "owner" do |binding|
        span binding, :class => "field-header" do |binding|
          concat("Owner:", binding)
        end
        common_display_pmr_owner(binding, call)
      end
    end

    def display_pmr_resolver(binding, call)
      td binding, :class => "resolver" do |binding|
        span binding, :class => "field-header" do |binding|
          concat("Resolver:", binding)
        end
        common_display_pmr_resolver(binding, call)
      end
    end
  end
end
