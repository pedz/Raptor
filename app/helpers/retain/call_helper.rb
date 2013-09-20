# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  module CallHelper

    Condor_URL = "http://tcp237.austin.ibm.com/condor/"
    APAR_Regexp = Regexp.new('\bi[vxyz][0-9][0-9][0-9][0-9][0-9]\b', Regexp::IGNORECASE)
    AMT_URL = "https://amt.austin.ibm.com/aparmgt/aparmgt.html?action=view&record_num="
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
    def show_line(line, index, tz, id_prefix = 'line')
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
        temp = html_escape(line.text)
        # Replace spaces with non-breaking spaces.
        # If we do it last, then the links get mucked with.
        # Need to see if a <pre> tag could be used somehow.
        temp = temp.gsub(/ /, '&nbsp;')

        # EBCDIC => UTF8      -- meaning
        # \x32   => \x16      -- Normal Protected
        # \x22   => \xc2 \x82 -- Normal Unprotected
        # \x3a   => \xc2 \x9a -- High Intensity Protected
        # \x2a   => \xc2 \x8a -- High Intensity Unprotected
        # The following four lines no longer work with UTF-8... I need
        # to go fix them TODO
        temp = temp.gsub("\u0016",     '</span><span class="normal-protected">&nbsp;')
        temp = temp.gsub("\u0082", '</span><span class="normal-unprotected">&nbsp;')
        temp = temp.gsub("\u009a", '</span><span class="intensified-protected">&nbsp;')
        temp = temp.gsub("\u008a", '</span><span class="intensified-unprotected">&nbsp;')

        # Find APARs and link them to Condor
        temp = temp.gsub(APAR_Regexp, "<a href=\"#{Condor_URL}swinfos/\\0\">\\0</a>")
        # Find references to APAR drafts
        temp = temp.gsub(AMT_Regexp1, "<a href=\"#{AMT_URL}\\1\">\\0</a>")
        temp = temp.gsub(AMT_Regexp2, "<a href=\"#{AMT_URL}\\1\">\\0</a>")
        temp = temp.gsub(AMT_Regexp3, "<a href=\"#{AMT_URL}\\1\">\\0</a>")
        text_line = temp
      end
      render(:partial => "shared/retain/show_line",
             :locals => {
               :id_prefix => id_prefix,
               :text_line => text_line,
               :div_string => div_string,
               :span_classes => span_classes,
               :line => line,
               :index => index,
               :page => page })
    end

    def display_update_button(binding)
      span binding, :class => 'call-update-span' do |binding|
        concat(button("Update Call", "$(\"call-update-div\").toggleForm();"))
      end
    end

    def display_update_form(binding, call)
      div(binding,
           :id => 'call-update-div',
           :class => 'call-update-container') do |binding|
        call_update = CallUpdate.new(call)
        concat(render(:partial => 'shared/retain/call_update',
                      :locals => { :call_update => call_update }))
      end
    end

    def exec_summary_button(binding)
      span binding, :class => 'call-fi5312-span' do |binding|
        concat(button("Exec Summary", "$(\"call-fi5312-div\").toggleForm();"))
      end
    end

    def exec_summary_form(binding, call)
      div(binding,
           :id => 'call-fi5312-div',
           :class => 'call-fi5312-container') do |binding|
        call_fi5312 = CallFi5312.new(call)
        concat(render(:partial => "shared/retain/exec_summary_form",
                      :locals => { :call_fi5312 => call_fi5312 }))
      end
    end

    def opc_button(binding)
      span binding, :class => 'opc-span' do |binding|
        concat(button("OPC", "$(\"opc-div\").toggleForm();"))
      end
    end

    def opc_form(binding, call)
      add_page_setting("opc_#{call.to_id}", call.pmr.opc)
      div(binding,
           :id => 'opc-div',
           :class => 'opc-container') do |binding|
        opc = Retain::CallOpc.new(call)
        concat(render(:partial => "shared/retain/opc_form",
                      :locals => { :opc => opc }))
      end
    end

    def display_pmr_owner(binding, call)
      td binding, :class => "owner" do |binding|
        span binding, :class => "field-header" do |binding|
          concat("Owner:")
        end
        common_display_pmr_owner(binding, call)
      end
    end

    def display_pmr_resolver(binding, call)
      td binding, :class => "resolver" do |binding|
        span binding, :class => "field-header field-right" do |binding|
          concat("Resolver:")
        end
        common_display_pmr_resolver(binding, call)
      end
    end

    def display_pmr_comments(binding, call)
      td binding do |binding|
        common_display_pmr_comments(binding, call)
      end
    end

    def make_call_link(binding, my_call, text, link_param)
      unless link_param.nil?
        if my_call.to_param == link_param
          lead = "*"
        else
          lead = "&nbsp;"
        end
        concat(link_to("#{lead}#{text}: #{link_param}", combined_call_path(link_param)) + "<br/>\n")
      end
    end

    def call_list(binding, call)
      pmr = call.pmr
      param = call.to_param
      calls = []
      calls << "Primary: #{pmr.primary_param}" if pmr.primary_param
      calls << "Sec 1: #{pmr.secondary_1_param}" if pmr.secondary_1_param
      calls << "Sec 2: #{pmr.secondary_2_param}" if pmr.secondary_2_param
      calls << "Sec 3: #{pmr.secondary_3_param}" if pmr.secondary_3_param
      calls = calls.join("<br/>\n")
      # If we know for sure its a backup
      if call.p_s_b == "B"
        text = "Backup"
      else
        # Otherwise, try and figure out
        case param
        when pmr.primary_param
          text = "Primary"
        when pmr.secondary_1_param
          text = "Sec 1"
        when pmr.secondary_2_param
          text = "Sec 2"
        when pmr.secondary_3_param
          text = "Sec 3"
        else
          text = "Backup"
        end
      end
      span binding, :id => 'call-list' do |binding|
        span binding, :class => 'field-header' do |binding|
          concat("Call Type:")
        end
        span binding, :class => 'field' do |binding|
          concat(text)
        end
        popup binding do |binding|
          concat(calls)
        end
      end
    end
  end
end
