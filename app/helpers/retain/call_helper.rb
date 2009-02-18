module Retain
  module CallHelper

    Condor_URL = "http://p51.austin.ibm.com/condor/"
    APAR_Regexp = Regexp.new('\bi[xyz][0-9][0-9][0-9][0-9][0-9]\b', Regexp::IGNORECASE)
    AMT_URL = "https://reports.austin.ibm.com/aparmgt/aparmgt.html?action=view&record_num="
    # Matches "top services" initial entry of "AMT record 1234"
    AMT_Regexp1 = Regexp.new('AMT&nbsp;record&nbsp;([0-9]+)')
    # Matches top services entry when the APAR is created
    AMT_Regexp2 = Regexp.new('\(AMT&nbsp;([0-9]+)\)')
    # Matches what people more often write: "apar draft 1234"
    AMT_Regexp3 = Regexp.new('apar&nbsp;draft&nbsp;([0-9]+)', Regexp::IGNORECASE)

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
        text_line = line.text.
          # Replace spaces with non-breaking spaces.
          # If we do it last, then the links get mucked with.
          # Need to see if a <pre> tag could be used somehow.
          gsub(/ /, '&nbsp;').
          # EBCDIC => UTF8      -- meaning
          # \x32   => \x16      -- Normal Protected
          # \x22   => \xc2 \x82 -- Normal Unprotected
          # \x3a   => \xc2 \x9a -- High Intensity Protected
          # \x2a   => \xc2 \x8a -- High Intensity Unprotected
          gsub("\x16",     '</span><span class="normal-protected">&nbsp;').
          gsub("\xc2\x82", '</span><span class="normal-unprotected">&nbsp;').
          gsub("\xc2\x9a", '</span><span class="intensified-protected">&nbsp;').
          gsub("\xc2\x8a", '</span><span class="intensified-unprotected">&nbsp;').
          # Find APARs and link them to Condor
          gsub(APAR_Regexp, "<a href=\"#{Condor_URL}swinfos/\\0\">\\0</a>").
          # Find references to APAR drafts
          gsub(AMT_Regexp1, "<a href=\"#{AMT_URL}\\1\">\\0</a>").
          gsub(AMT_Regexp2, "<a href=\"#{AMT_URL}\\1\">\\0</a>").
          gsub(AMT_Regexp3, "<a href=\"#{AMT_URL}\\1\">\\0</a>")
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
        concat(button("Update Call", "$(\"call_update_span\").toggleCallUpdateForm();"), binding)
      end
    end

    def display_update_form(binding, call)
      span(binding,
           :id => 'call_update_span',
           :class => 'call-update-container') do |binding|
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

    def display_pmr_comments(binding, call)
      td binding do |binding|
        common_display_pmr_comments(binding, call)
      end
    end
  end
end
