# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require 'time'

module Retain
  module QsHelper

    DISP_LIST = [
                 :call_button, :link_etc, :pri_sev, :p_s_b,
                 :biggem, :age, :jeff, :next_ct, :ct,
                 :dispatch, :sg, :psar_time
                ]

    HELP_TEXT = <<-EOF
	<tr>
	  <th colspan='#{DISP_LIST.length}'>
	    Click on column headings to sort by that column
	  </th>
	</tr>
      EOF

    # The "1" style of header and body is the original version
    def display_qs_headers(binding)
      thead binding do |binding|
        concat(HELP_TEXT)
        tr binding do |binding|
          DISP_LIST.map { |sym| self.send sym, binding, true, nil }.join("\n")
        end
      end
    end

    def qs_show_time(time)
      h, m = time.divmod(60)
      sprintf("%02d:%02d", h, m)
    end

    def sum_psar_time(psars)
      psars.inject(0) { |sum, psar| sum += psar.chargeable_time_hex }
    end

    def display_qs_footer(binding)
      total_time = @todays_psars.inject(0) { |sum, psar_thing|
        sum += sum_psar_time(psar_thing[1])
      }
      pmr_ids = @queue.calls.map { |call| call.pmr.id }
      other_time = @todays_psars.inject(0) { |sum, psar_thing|
        pmr_id, psars = psar_thing
        unless pmr_id && pmr_ids.include?(pmr_id)
          sum += sum_psar_time(psars)
        end
        sum
      }
      tfoot binding do |binding|
        psar_index = DISP_LIST.index(:psar_time)
        tr binding do |binding|
          td binding, :colspan => psar_index, :class => 'other-time' do |binding|
            concat("Other PMRs")
          end
          td binding do |binding|
            concat(qs_show_time(other_time))
          end
          if (diff = (DISP_LIST.length - psar_index - 1)) > 0
            td binding, :colspan => diff do |binding|
              concat("&nbsp;")
            end
          end
        end
        tr binding do |binding|
          td binding, :colspan => psar_index, :class => 'total-time' do |binding|
            concat("Day's Total")
          end
          td binding do |binding|
            concat(qs_show_time(total_time))
          end
          if (diff = (DISP_LIST.length - psar_index - 1)) > 0
            td binding, :colspan => diff do |binding|
              concat("&nbsp;")
            end
          end
        end
      end
    end

    def render_row(binding, call)
      hit_cache = true
      # Change: I've decided to make the qs view user specific.  In
      # particular the 'updated' class I want to be for a particular
      # user so that they can look at a glance if the PMR has been
      # updated since they last looked at it.  Coupled with this is a
      # change that updated will be only if there is not a PSAR from
      # the given user for the particular PMR since the last update.
      # i.e. they can make the call be "not updated" by adding time to
      # it without an update.  This will allow each user to make the
      # calls as "not updated" without any conflicts.  I'm doing it
      # this way rather than a private flag because really, users
      # should add time when they scan the updates for the PMR.  The
      # third piece of this puzzle that I'm adding is some "ack"
      # button to add 6 minutes of time to the PMR without adding any
      # additional text.
      # So... the first step is to make the cache tags contain the
      # user's id...
      if (last_psar = @user_registration.psars.find(:last, :conditions => { :pmr_id => call.pmr_id}))
        suffix = last_psar.psar_file_and_symbol
      else
        suffix = application_user.ldap_id
      end
      tag = call.cache_tag("qs") + suffix
      cache(tag) do
        logger.debug("building fragment for #{tag}")
        hit_cache = false
        row_class = call_class(call)
        row_title = call_title(row_class)
        tr(binding,
           :id => "tr-#{call.to_param.gsub(",", "-")}",
           :class => row_class + " pmr-row",
           :title => row_title) do |binding|
          DISP_LIST.map { |sym| self.send sym, binding, false, call }.join("\n")
        end
      end
      # logger.debug("reused fragment for #{tag}") if hit_cache
    end

    private

    BIGGEM_COLUMNS = [
                      [ :customer, :owner, :resolver, :next_queue ],
                      [ :comments, :component_check, :call_update_field ],
                      [ :call_update_form ]
                     ]
    def biggem(binding, header, call)
      # logger.debug("QS: biggem #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'biggem' do |binding|
          table binding, :class => 'nested-table' do |binding|
            thead binding do |binding|
              BIGGEM_COLUMNS.inject("") do |memo, cols|
                tr binding do |binding|
                  cols.each { |sym|
                    self.send sym, binding, header, call
                  }
                  concat("\n")
                end
              end
            end
            # The html validator says I gotta have a body.
            tbody binding do |binding|
              tr binding do |binding|
                td binding do |binding|
                end
              end
            end
          end
        end
      else
        td binding, :class => 'biggem' do |binding|
          table binding, :class => 'nested-table' do |binding|
            tbody binding do |binding|
              BIGGEM_COLUMNS.inject("") do |memo, cols|
                tr binding do |binding|
                  cols.map { |sym|
                    self.send sym, binding, header, call
                  }
                  concat("\n")
                end
              end
            end
          end
        end
      end
    end
    
    CompRegex = Regexp.new("CompID:(.........)")
    GoodComps = [
                 "5639H72BE",
                 "5639JSI00",
                 "5639N3701",
                 "5639N3702",
                 "5639N3703",
                 "5639N3704",
                 "5639N4700",
                 "5639NES00",
                 "5639P3500",
                 "5655R1200",   # Digi Lan RAN
                 "566497801",
                 "5697G4300",
                 "5698R2600",
                 "5698R2700",
                 "5724I23IS",
                 "5724I23LP",
                 "5724I23LX",
                 "5724K69LX",
                 "5724K69WX",
                 "5724N02ID",
                 "5724N0500",
                 "5724N0501",
                 "5724N05LX",
                 "5724N94LX",
                 "5724N94WX",
                 "5724V6301",
                 "5724V6302",
                 "5724V6303",
                 "5724V6304",
                 "5724V6401",
                 "5724V6402",
                 "5724V6403",
                 "5724V6404",
                 "576543300",
                 "5765AEPAS",
                 "5765AEPLS",
                 "5765AEZ00",
                 "5765AVE00",
                 "5765DR100",
                 "5765DR1AV",
                 "5765DR1AX",
                 "5765DR1DC",
                 "5765DR1DS",
                 "5765DR1LV",
                 "5765DR1PC",
                 "5765DR1PP",
                 "5765DR1PS",
                 "5765DRPAA",
                 "5765DRPAS",
                 "5765DRPAU",
                 "5765DRPAV",
                 "5765DRPHP",
                 "5765DRPIA",
                 "5765DRPLA",
                 "5765DRPLS",
                 "5765DRPLU",
                 "5765DRPLV",
                 "5765DRPMT",
                 "5765DRPNM",
                 "5765DRPSM",
                 "5765DRPUI",
                 "5765E6100",
                 "5765E6110",
                 "5765E6111",
                 "5765E6121",
                 "5765E6199",   # AIX 5.1 Extended
                 "5765E6200",   # AIX 5.2
                 "5765E6221",
                 "5765E6299",
                 "5765E62T8",
                 "5765E62T9",
                 "5765E6800",
                 "5765E6900",
                 "5765E7200",
                 "5765E7400",
                 "5765E7701",
                 "5765E8200",
                 "5765E8500",
                 "5765E8800",
                 "5765E8810",
                 "5765E88LH",
                 "5765E88LX",
                 "5765EWCDM",
                 "5765EWCMS",
                 "5765EWIDM",
                 "5765EWIMS",
                 "5765EWPDM",
                 "5765EWPMS",
                 "5765F07AP",
                 "5765F07LP",
                 "5765F07LX",
                 "5765F07SO",
                 "5765F07WN",
                 "5765F5500",
                 "5765F6200",   # HACMP 541 Base
                 "5765F6210",
                 "5765F6220",
                 "5765F6299",
                 "5765F62OR",
                 "5765F6700",
                 "5765F6701",
                 "5765F8200",
                 "5765F8300",
                 "5765F8400",
                 "5765G0101",
                 "5765G0300",   # AIX 5.3
                 "5765G0310",
                 "5765G0320",
                 "5765G0330",
                 "5765G0340",
                 "5765G0350",
                 "5765G0360",
                 "5765G0370",
                 "5765G0381",
                 "5765G03BE",
                 "5765G03T4",
                 "5765G03T5",
                 "5765G03T6",
                 "5765G03T7",
                 "5765G0600",
                 "5765G1600",
                 "5765G1620",
                 "5765G16LP",
                 "5765G17LP",
                 "5765G18LP",
                 "5765G22OG",
                 "5765G2400",    # CSS For AIX
                 "5765G2500",
                 "5765G2601",
                 "5765G2602",
                 "5765G28ER",
                 "5765G28ET",
                 "5765G3100",
                 "5765G3200",
                 "5765G3300",
                 "5765G3400",   # VIO Server
                 "5765G3450",
                 "5765G3460",
                 "5765G34BE",
                 "5765G34IV",
                 "5765G6200",   # AIX 6.1
                 "5765G6205",
                 "5765G6206",
                 "5765G6210",
                 "5765G6240",
                 "5765G6245",
                 "5765G62AM",
                 "5765G62BE",
                 "5765G62T0",
                 "5765G6500",
                 "5765G66AP",
                 "5765G66BS",
                 "5765G67LP",
                 "5765G6800",
                 "5765G70LP",
                 "5765G7100",
                 "5765G7300",
                 "5765G7800",
                 "5765G8100",
                 "5765G8200",
                 "5765G8300",
                 "5765G83BE",
                 "5765H1000",
                 "5765H1100",
                 "5765H2300",
                 "5765H2310",
                 "5765H2320",
                 "5765IMPAI",
                 "5765IMPLI",
                 "5765L4010",
                 "5765L4011",
                 "5765PEA00",
                 "5765PEA01",
                 "5765PEA02",
                 "5765PEA03",
                 "5765PEL00",
                 "5765PEPLI",
                 "5765WPM00",
                 "5767DR1DC",
                 "5799GPS00",
                 "5799GZW00",
                 "5799HCK00",
                 "5799QT100",
                 "5799SPT00",
                 "9100BPA00",
                 "9100FED00",
                 "9100FSP00",
                 "9100HMC00",
                 "9100HMC50",
                 "9100HMC60",
                 "9100HMC70",   # HMC code
                 "9100HMCBE",
                 "9100HMCNM",
                 "9100PFW00",
                 "9100PHY00",
                 "9100SPC00",
                 "9400DG4BP",
                 "9400DG4FE",
                 "9400DG4FS",
                 "9400DG4PF",
                 "9400DG4PH",
                 "9400DG4SP",
                 "RUTHTEST3"
                ]
    def component_check(binding, header, call)
      # logger.debug("QS: bomponent_check #{call.nil? ? "header" : call.to_param}")
      if header
        th binding do |binding|
          concat("Component")
        end
      else
        pmr = call.pmr
        if pmr.component_id.nil? || (pmr_comp = pmr.component_id[0,9]).blank?
          pmr_comp = "blank"
        end
        # logger.debug("QS: comp = '#{pmr_comp}'")
        entitled_comp = pmr.information_text_lines.inject(nil) { |comp, text_line|
          unless comp
            if (md = CompRegex.match(text_line.text))
              comp = md[1]
            end
          end
          comp
        }
        if entitled_comp.nil?
          td_class = "wag-wag"
          td_title = "Not entitled"
        elsif entitled_comp != pmr_comp
          td_class = "wag-wag"
          td_title = "Entitled for #{entitled_comp}"
        elsif GoodComps.include?(pmr_comp)
          td_class = "good"
          td_title = "Valid entitled component"
        else
          td_class = "warn"
          td_title = "Entitled component not valid"
        end
        # Hack for now -- WT does not seem to be checked and Hitachi
        # does not seem to be checked.
        if pmr.country != "000"
          td_class = "good"
          td_title = "WT not checked"
        elsif pmr.customer.customer_number == "4285384"
          td_class = "good"
          td_title = "Hitachi not checked"
        end
        td binding, :class => td_class, :title => td_title do |binding|
          concat(pmr_comp)
        end
      end
    end

    # Dispath / Undispatch
    def dispatch(binding, header, call)
      if header
        th binding, :class => 'dispatch' do |binding|
          concat("Dispatch<br/>Undispatch")
        end
      else
        td binding, :class => 'dispatch' do |binding|
          if call.is_dispatched
            if call.dispatched_employee == @retain_user_connection_parameters.signon
              concat(link_to_remote("Undispatch", :url => dispatch_combined_call_path(call)))
            else
              concat("N/A")
            end
          else
            concat(link_to_remote("Dispatch", :url => dispatch_combined_call_path(call)))
          end
        end
      end
    end

    # Service Given
    def sg(binding, header, call)
      if header
        th binding, :class => 'text' do |binding|
          concat("SG")
        end
      else
        sig_text = nil
        if (sg_lines = call.pmr.service_given_lines).empty?
          title = "Get Off your ASS!!!"
          sg = "NG"
        else
          last_sg = sg_lines.last
          sig_text = call.pmr.all_text_lines.reverse.find { |line|
            line.text_type == :signature && line.line_number < last_sg.line_number
          }
          title = Retain::SignatureLine.new(sig_text.text).date.new_offset(signon_user.tz).strftime("%b %d, %Y")
          sg = last_sg.service_given
          link = combined_call_path(call)
        end
        td binding, :class => 'service-given text', :title => title do |binding|
          if sig_text
            hash = hash_for_combined_call_path(:id => call.to_param)
            hash.merge!(:anchor => "line_#{sig_text.line_number}")
            href = url_for(hash)
            a binding, :href => href do |binding|
              concat(sg)
            end
          else
            concat(sg)
          end
        end
      end
    end

    def psar_time(binding, header, call)
      if header
        th binding, :class => 'time' do |binding|
          concat("Time")
          if (r = push_page_settings)
            concat(r)
          end
        end
      else
        td binding, :class => 'colon-time time' do |binding|
          pmr_id = call.pmr.id
          # logger.debug("qs_helper#psar_time: pmr_id=#{pmr_id}")
          if psars = @todays_psars.delete(pmr_id)
            pmr_time = sum_psar_time(psars)
          else
            pmr_time = 0
          end
          concat(qs_show_time(pmr_time))
          if (r = push_page_settings)
            concat(r)
          end
        end
      end
    end

    def call_update_form(binding, header, call)
      # logger.debug("QS: call_update_form #{call.nil? ? "header" : call.to_param}")
      if header
        th(binding,
           :class => 'call-update-container',
           :colspan => 4) do |binding|
          concat("")
        end
      else
        td(binding,
           :id => "call_update_td_#{call.ppg}",
           :class => 'call-update-container',
           :style => 'display: none;',
           :colspan => 4) do |binding|
          call_update = CallUpdate.new(call)
          # logger.debug("call-update-psar-update-psar-service-code = #{call_update.psar_update.psar_service_code}")
          concat(render(:partial => "shared/retain/call_update",
                        :locals => { :call_update => call_update }))
        end
      end
    end

    def call_update_field(binding, header, call)
      # logger.debug("QS: call_update_field #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'update' do |binding|
          concat("Update")
        end
      else
        td binding, :class => 'update' do |binding|
          concat(button("U#{call.ppg}", "$(\"call_update_td_#{call.ppg}\").toggleCallUpdateForm();"))
        end
      end
    end
    
    def customer(binding, header, call)
      # logger.debug("QS: customer #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'customer' do |binding|
          concat("Customer".center(28).gsub(/ /, '&nbsp;'))
        end
      else
        pmr = call.pmr
        if pmr.customer && pmr.customer.pat
          classes = "customer pat"
          pretitle = "PAT customer: "
        else
          classes = "customer"
          pretitle = ""
        end
        if pmr.problem_e_mail.nil? || (mail = pmr.problem_e_mail.strip).blank?
          title = pretitle + "No email given"
          td binding, :title => title, :class => classes do |binding|
            concat(call.nls_customer_name.ljust(28).gsub(/ /, '&nbsp;'))
          end
        else
          title = pretitle + "Click to send email to #{mail}"
          href = "mailto:#{mail}?subject=#{pmr.pbc.upcase}"
          td binding, :title => title, :class => classes do |binding|
            a binding, :href => href do |binding|
              concat(h(call.nls_customer_name).ljust(28).gsub(/ /, '&nbsp;'))
            end
          end
        end
      end
    end

    def comments(binding, header, call)
      # logger.debug("QS: comments #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'comments', :colspan => 2 do |binding|
          concat("Comments")
        end
      else
        td binding, :colspan => 2, :class => 'comments' do |binding|
          common_display_pmr_comments(binding, call)
        end
      end
    end

    def ct(binding, header, call)
      # logger.debug("QS: ct #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'ct' do |binding|
          concat("CT")
        end
      else
        td binding, :class => 'ct' do |binding|
          concat(link_to_remote("ct", :url => ct_combined_call_path(call)))
        end
      end
    end
    
    def call_button(binding, header, call)
      # logger.debug("QS: call_button #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'call-button number' do |binding|
          concat("Sel#")
        end
      else
        td binding, :class => 'call-button number' do |binding|
          concat(button_url("#{call.ppg}", call))
        end
      end
    end

    def p_s_b(binding, header, call)
      # logger.debug("QS: p_s_b #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'p-s-b' do |binding|
          concat("S")
        end
      else
        td binding, :class => 'p-s-b' do |binding|
          if call.p_s_b
            concat(call.p_s_b)
          else
            concat('?')
          end
        end
      end
    end
    
    def cust_email(header, call)
      return "<th class='cust-email'>Email Customer</th>" if header
      pmr = call.pmr
      if (mail = pmr.problem_e_mail.strip).blank?
        td :class => 'cust-email' do
          "No Email Given"
        end
      else
        href = "mailto:#{mail}?subject=#{pmr.pbc.upcase}"
        td :class => 'cust-email' do
          a :href => href do
            mail
          end
        end
      end
    end

    def qs_ecpaat_lines(call)
      pmr = call.pmr
      temp_hash = pmr.ecpaat
      tz = pmr.customer.tz
      if tz
        n = DateTime.now.new_offset(tz)
        tz_text = n.strftime("%a, %d %b %Y %H:%M")
      else
        tz_text = "Can't retrieve Customer Record"
      end
      
      temp_lines = [ "<span class='ecpaat-heading'>Customer: </span>" +
                     "#{h(call.nls_customer_name)}" ]
      temp_lines << [ "<span class='ecpaat-heading'>Comments: </span>" +
                     "#{h(call.comments)}" ]
      temp_lines << [ "<span class='ecpaat-heading'>Customer Time of Day: </span>" +
                      "#{h(tz_text)}" ]
      ecpaat_temp_lines = []
      Cached::Pmr::ECPAAT_HEADINGS.each { |heading|
        if (lines = temp_hash[heading]).nil?
          ecpaat_temp_lines << ("<span class='ecpaat-heading-missing'>" +
                         h(heading) + ": " + "</span>")
        else
          ecpaat_temp_lines << ("<span class='ecpaat-heading'>" +
                         h(heading) + ": " + "</span>" +
                         h(lines.shift))
          lines = lines[0 .. 4] + [ " ..." ] if lines.length > 5
          ecpaat_temp_lines += lines.map{ |l| h(l) }
        end
      }
      # This could be simpler but the middle br I want something but I
      # can't put <hr/> due to html validation
      a = temp_lines.join("<br/>\n")
      b = "<br/>\n"
      c = ecpaat_temp_lines.join("<br/>\n")
      # logger.debug("encoding for a is #{a.encoding}")
      # logger.debug("encoding for b is #{b.encoding}")
      # logger.debug("encoding for c is #{c.encoding}")
      a + b + c
    end

    def link_etc(binding, header, call)
      # logger.debug("QS: link_etc #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'link-etc text' do |binding|
          concat("Prblm,bnc,cty<br/>Dispatched By")
        end
      else
        class_list = 'link-etc text'
        if call.pmr.ecpaat_complete?
          title = 'ecpaat is complete'
        else
          class_list << ' ecpaat-incomplete'
          title = 'ecpaat is incomplete'
        end
        td binding, :class => class_list, :title => title do |binding|
          div binding, :class => 'links' do |binding|
            a binding, :class => 'pmr-link', :href => url_for(call) do |binding|
              span binding, :style => "text-decoration: underline" do |binding|
                concat(call.pmr.pbc)
                if call.is_dispatched
                  concat("<br/>#{call.dispatched_employee_name}")
                end
              end
              popup binding do |binding|
                concat(qs_ecpaat_lines(call))
              end
            end
          end
        end
      end
    end

    # Returns a class for the call row based upon the call
    def call_class(call)
      return "system-down" if call.system_down
      return "initial-response" if call.needs_initial_response?
      if call.pmr.signature_lines.empty?
        last_line = nil
        last_signature_name = "Unknown"
      else
        last_line = call.pmr.signature_lines.last
        last_signature_name = (name = last_line.name) &&
          name.gsub(/ +$/, '')
      end

      # "updated" means that there is an update since the last update
      # of the user.  So... if the last signature is from the user or
      # if there is a PSAR from the current user since the last
      # signature we say that it is "normal", othewise we say it is
      # "updated".
      if (name = @user_registration.name)
        user_registration_name = name.gsub(/ +$/, '')
      else
        user_registration_name = ""
      end
      return "normal" if user_registration_name == last_signature_name
      # Find the psars for this user and PMR
      last_psar = @user_registration.psars.find(:last, :conditions => { :pmr_id => call.pmr_id})
      if last_psar && last_line && last_psar.stop_time_date && last_line.date
        logger.debug("PMR: #{call.pmr.problem},#{call.pmr.branch},#{call.pmr.country}")
        logger.debug("last_psar.stop_time_date = #{last_psar.stop_time_date}")
        logger.debug("last_line.date = #{last_line.date}")
        logger.debug("last_psar.stop_time_date > last_line.date = #{last_psar.stop_time_date > last_line.date}")
        return "normal" if last_psar.stop_time_date > last_line.date
      end
      return "updated"
    end

    # Determines the title string for a call
    def call_title(call_class)
      case call_class
      when 'system-down'
        'System is down'
      when 'initial-response'
        'Under initial response time guidelines'
      when 'normal'
        'Under normal CT time guidelines'
      when 'updated'
        'Normal CT guidelines; call last updated by someone other than call owner'
      else
        'unknown row class'
      end
    end

    def owner(binding, header, call)
      # logger.debug("QS: owner #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'owner not-editable' do |binding|
          width = Retain::Fields.field_width(:pmr_owner_name)
          concat("Owner".center(width).gsub(/ /, '&nbsp;'))
        end
      else
        td binding, :class => "owner" do |binding|
          common_display_pmr_owner(binding, call)
        end
      end
    end

    def resolver(binding, header, call)
      # logger.debug("QS: resolver #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'resolver not-editable' do |binding|
          width = Retain::Fields.field_width(:pmr_resolver_name)
          concat("Resolver".center(width).gsub(/ /, '&nbsp;'))
        end
      else
        td binding, :class => "resolver" do |binding|
          common_display_pmr_resolver(binding, call)
        end
      end
    end
    
    def next_queue(binding, header, call)
      # logger.debug("QS: next_queue #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => "next-queue not-editable" do |binding|
          width = (Retain::Fields.field_width(:next_queue) + 1 # +1 for commma
                   Retain::Fields.field_width(:h_or_s) + 1 +
                   Retain::Fields.field_width(:next_center))
          concat("Next Queue".center(width).gsub(/ /, '&nbsp;'))
        end
      else
        td binding, :class => "next-queue" do |binding|
          common_display_pmr_next_queue(binding, call)
        end
      end
    end

    def pri_sev(binding, header, call)
      # logger.debug("QS: pri_sev #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'pri-sev text' do |binding|
          concat("P/S")
        end
      else
        p = call.priority
        s = call.severity
        if p == s
          td_class =  "good"
          td_title = "Nothing wrong here"
        else
          td_class = "wag-wag"
          td_title = "Priority and Severity should match"
        end
        td_class << " pri-sev text"
        td binding, :title => td_title, :class => td_class do |binding|
          concat("#{p}/#{s}")
        end
      end
    end

    def age(binding, header, call)
      # logger.debug("QS: age #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'age number' do |binding|
          concat("Age")
        end
      else
        age_value = call.pmr.age.round
        if age_value > 100
          age_class = "wag-wag"
          age_title = "Over 100 days old"
        else
          age_class = "normal"
          age_title = "Young pup"
        end
        age_class << ' age number'
        td(binding,
           :title => age_title,
           :class => age_class) do |binding|
          concat("#{age_value}")
        end
      end
    end

    # Calculate the Jeff Smith days...
    MULT = [ 0, 10, 2, 0.5, 0.1 ]
    JEFF_TEXT = "Jeff Smith originated the concept of Severity Days. He was the " +
      "original level two manager of the AIX RS/6000 version 3 change team"
    SEV_TEXT = "Severity Days is the age of the PMR in days multiplied by a " +
      "factor based upon the current severity"
    def jeff(binding, header, call)
      # logger.debug("QS: jeff #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'jeff number' do |binding|
          span binding, :title => JEFF_TEXT do |binding|
            concat("JS")
          end
          concat("<br />")
          span binding, :title => SEV_TEXT do |binding|
            concat("SevD")
          end
        end
      else
        pmr = call.pmr
        jeff_days = (MULT[call.severity] * pmr.age).round
        if jeff_days > 300
          jeff_class = "wag-wag"
          jeff_title = "Over 300 Jeff Days"
        elsif jeff_days > 50
          jeff_class = "warn"
          jeff_title = "Over 50 Jeff Days"
        else
          jeff_class = "normal"
          jeff_title = "You are a happy puppy"
        end
        jeff_class << " jeff number"
        td binding, :class => jeff_class, :title => jeff_title do |binding|
          concat("#{jeff_days}")
        end
      end
    end

    def last_ct(call)
      last_ct_time = call.pmr.last_ct_time.new_offset(signon_user.tz)
      td do
        "#{last_ct_time.strftime("%a, %d %b %Y %H:%M")}"
      end
    end

    # Return the UTC time of the next business day in the given time
    # zone... how am I going to do this?
    def start_next_bus_day(time, tz)
      their_time = time + tz
    end

    def ct_initial_response_requirement(call)
      # logger.debug("ct_initial_response_requirement for #{call.to_param}")
      pmr = call.pmr
      customer = pmr.customer
      entry_time = call.center_entry_time
      if pmr.country == '000'       # U. S.
        # logger.debug("initial response US")

        # Sev 1  System Down during Primeshift or Offshift: Initial
        #        customer callback - every effort should be made to
        #        contact customer within 1 hr
        if call.system_down
          # logger.debug("system down")
          return entry_time + (1.to_r / 24) # clock hours
        end
        
        # Sev 1 Primeshift or Offshift: Initial customer callback is
        #       within 2 business hours, but try for one hour
        if call.severity == 1
          # logger.debug("sev 1")
          return customer.business_hours(entry_time, 2)
        end
        
        # Sev 2,3,4 during Primeshift: Initial customer callback is
        #           within 2 business hours
        # logger.debug("center is #{pmr.center.center}")
        # logger.debug("entry time is #{entry_time}")
        if pmr.center.prime_shift(entry_time)
          # logger.debug("prime_shift")
          return customer.business_hours(entry_time, 2)
        end
        
        # SEV 2,3,4 during Offshift: Initial customer callback is the
        #           next business day
        # logger.debug("off shift")
        return customer.business_days(entry_time, 1)
      else
        # logger.debug("initial response WT #{call.severity.class}")
        case call.severity
        when 0                  # encounted a PMH with a severity of 0... go figure.
          return customer.business_hours(entry_time, 2)
        when 1
          return customer.business_hours(entry_time, 2)
        when 2
          return customer.business_hours(entry_time, 4)
        when 3
          return customer.business_hours(entry_time, 8)
        when 4
          return customer.business_hours(entry_time, 8)
        end
      end
      raise "Did not figure out response time #{call.pmr.to_param}"
    end

    FOLLOW_UP_RESPONSE_TIME = [ 0, 1, 2, 5, 5 ] # business days

    def ct_normal_response_requirement(call)
      # logger.debug("ct_normal_response_requirement for #{call.to_param}")
      pmr = call.pmr
      customer = pmr.customer
      days = FOLLOW_UP_RESPONSE_TIME[call.severity]
      start_time = pmr.last_ct_time
      # logger.debug("TIME: ---- #{start_time}")
      customer.business_days(start_time, days)
    end

    def next_ct(binding, header, call)
      # logger.debug("QS: next_ct #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'next-ct my-date' do |binding|
          concat("Next CT")
        end
      else
        # logger.debug("pmr's center is #{call.pmr.center.center}")
        is_initial = call.needs_initial_response?
        if is_initial
          nt = ct_initial_response_requirement(call)
          entry_time = call.center_entry_time.new_offset(signon_user.tz)
          title = "Entry Time: #{entry_time.strftime("%a, %d %b %Y %H:%M")}"
        else
          nt = ct_normal_response_requirement(call)
          last_ct_time = call.pmr.last_ct_time.new_offset(signon_user.tz)
          title = "Last CT: #{last_ct_time.strftime("%a, %d %b %Y %H:%M")}"
        end
        
        
        now = DateTime.now
        if now > nt
          text = "CT Overdue"
          css_class = "wag-wag"
        else
          text = nt.new_offset(signon_user.tz).strftime("%a @ %H:%M<br />%b %d")
          now += 1
          if now > nt
            css_class = "warn"
          else
            css_class = "normal"
          end
        end
        css_class << ' next-ct'
        td binding, :class => css_class, :title => title do |binding|
          concat(text)
        end
      end
    end

    def customer_span(call)
      pmr = call.pmr
      if (mail = pmr.problem_e_mail.strip).blank?
        span :title => "No email given", :class => "customer" do
          call.nls_customer_name
        end
      else
        title = "Click to send email to #{mail}"
        href = "mailto:#{mail}?subject=#{pmr.pbc.upcase}"
        span :title => title, :class => "customer" do
          a :href => href do
            call.nls_customer_name
          end
        end
      end
    end

    [
     :a,
     :dd,
     :div,
     :dl,
     :dt,
     :li,
     :span,
     :table,
     :tbody,
     :td,
     :tfoot,
     :th,
     :thead,
     :tr,
     :ul
    ].each do |sym|
      eval("def #{sym}(binding, hash = { })
              @nesting ||= 0
              padding = \" \" * @nesting
              @nesting += 2
              concat(\"\#{padding}<#{sym}\#{hash.keys.inject(\"\") { |memo, key| memo += \" \#{key}='\#{hash[key]}'\"}}>\n\")
              yield(binding)
              concat(\"\#{padding}</#{sym}>\n\")
              @nesting -= 2
            end", nil, __FILE__, __LINE__ - 8)
    end

  end
end
