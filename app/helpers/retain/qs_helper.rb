require 'time'

module Retain
  module QsHelper

    DISP_LIST = [
                 :call_button, :link_etc, :pri_sev, :p_s_b,
                 :biggem,
                 :age, :jeff, :next_ct, :ct, :psar_time
                ]

    HELP_TEXT = <<-EOF
	<tr>
	  <th colspan='5'>
	    Click on column headings to sort by that column
	  </th>
	</tr>
      EOF

    # The "1" style of header and body is the original version
    def display_qs_headers(binding)
      thead binding do |binding|
        concat(HELP_TEXT, binding)
        tr binding do |binding|
          DISP_LIST.map { |sym| self.send sym, binding, true, nil, nil }.join("\n")
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

    def display_qs_body(binding)
      total_time = @todays_psars.inject(0) { |sum, psar_thing|
        sum += sum_psar_time(psar_thing[1])
      }
      tbody binding do |binding|
        @queue.calls.each_with_index do |call, index|
          tr binding, :class => call_class(call) + " pmr-row" do |binding|
            DISP_LIST.map { |sym| self.send sym, binding, false, call, index }.join("\n")
          end
        end
      end
      other_time = @todays_psars.inject(0) { |sum, psar_thing|
        sum += sum_psar_time(psar_thing[1])
      }
      tfoot binding do |binding|
        tr binding do |binding|
          td binding, :colspan => DISP_LIST.length - 1, :class => 'other-time' do |binding|
            concat("Other PMRs", binding)
          end
          td binding do |binding|
            concat(qs_show_time(other_time), binding)
          end
        end
        tr binding do |binding|
          td binding, :colspan => DISP_LIST.length - 1, :class => 'total-time' do |binding|
            concat("Day's Total", binding)
          end
          td binding do |binding|
            concat(qs_show_time(total_time), binding)
          end
        end
      end
    end

    private

    BIGGEM_COLUMNS = [
                      [ :customer, :owner, :resolver, :next_queue ],
                      [ :comments, :call_update_field ],
                      [ :call_update_form ]
                     ]
    def biggem(binding, header, call, index)
      logger.debug("QS: biggem #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'biggem' do |binding|
          table binding, :class => 'nested-table' do |binding|
            thead binding do |binding|
              BIGGEM_COLUMNS.inject("") do |memo, cols|
                tr binding do |binding|
                  cols.each { |sym|
                    self.send sym, binding, header, call, index
                  }
                  concat("\n", binding)
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
                    self.send sym, binding, header, call, index
                  }
                  concat("\n", binding)
                end
              end
            end
          end
        end
      end
    end
    
    def psar_time(binding, header, call, index)
      if header
        th binding do |binding|
          concat("Time", binding)
        end
      else
        td binding, :class => 'colon-time' do |binding|
          pmr_id = call.pmr.id
          logger.debug("qs_helper#psar_time: pmr_id=#{pmr_id}")
          if psars = @todays_psars.delete(pmr_id)
            pmr_time = sum_psar_time(psars)
          else
            pmr_time = 0
          end
          concat(qs_show_time(pmr_time), binding)
        end
      end
    end

    def call_update_form(binding, header, call, index)
      logger.debug("QS: call_update_form #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'call-update-container', :colspan => 4 do |binding|
          concat("", binding)
        end
      else
        td(binding,
           :id => "call_update_td_#{index+1}",
           :class => 'call-update-container',
           :colspan => 4) do |binding|
          call_update = CallUpdate.new(call)
          logger.debug("call-update-psar-update-psar-service-code = #{call_update.psar_update.psar_service_code}")
          concat(render(:partial => "shared/retain/call_update",
                        :locals => { :call_update => call_update }),
                 binding)
        end
      end
    end

    def call_update_field(binding, header, call, index)
      logger.debug("QS: call_update_field #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'update' do |binding|
          concat("Update", binding)
        end
      else
        td binding, :class => 'update' do |binding|
          concat(button("U#{index + 1}", "$(\"call_update_td_#{index + 1}\").toggleCallUpdateForm();"), binding)
        end
      end
    end
    
    def customer(binding, header, call, index)
      logger.debug("QS: customer #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'customer' do |binding|
          concat("Customer".center(28).gsub(/ /, '&nbsp;'), binding)
        end
      else
        pmr = call.pmr
        if (mail = pmr.problem_e_mail.strip).blank?
          td binding, :title => "No email given", :class => "customer" do |binding|
            concat(call.nls_customer_name.ljust(28).gsub(/ /, '&nbsp;'), binding)
          end
        else
          title = "Click to send email to #{mail}"
          href = "mailto:#{mail}?subject=#{pmr.pbc.upcase}"
          td binding, :title => title, :class => "customer" do |binding|
            a binding, :href => href do |binding|
              concat(h(call.nls_customer_name).ljust(28).gsub(/ /, '&nbsp;'), binding)
            end
          end
        end
      end
    end

    def comments(binding, header, call, index)
      logger.debug("QS: comments #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'comments', :colspan => 3 do |binding|
          concat("Comments", binding)
        end
      else
        td binding, :colspan => 3, :class => 'comments' do |binding|
          add_page_setting("comments_#{call.to_id}",
                           {
                             :url => alter_combined_call_path(call)
                           })
          span(binding,
               :id => "comments_#{call.to_id}",
               :class => "edit-name") do |binding|
            concat(call.comments, binding)
          end
        end
      end
    end

    def ct(binding, header, call, index)
      logger.debug("QS: ct #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'ct' do |binding|
          concat("CT", binding)
        end
      else
        td binding, :class => 'ct' do |binding|
          concat(link_to_remote("ct", :url => ct_combined_call_path(call)), binding)
        end
      end
    end
    
    def call_button(binding, header, call, index)
      logger.debug("QS: call_button #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'call-button' do |binding|
          concat("Sel#", binding)
        end
      else
        td binding, :class => 'call-button' do |binding|
          concat(button_url("C#{index + 1}", call), binding)
        end
      end
    end

    def p_s_b(binding, header, call, index)
      logger.debug("QS: p_s_b #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'p-s-b' do |binding|
          concat("S", binding)
        end
      else
        td binding, :class => 'p-s-b' do |binding|
          concat(call.p_s_b, binding)
        end
      end
    end
    
    def cust_email(header, call, index)
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
      Cached::Pmr::ECPAAT_HEADINGS.each { |heading|
        unless (lines = temp_hash[heading]).nil?
          temp_lines << ("<span class='ecpaat-heading'>" +
                         h(heading) + ": " + "</span>" +
                         h(lines.shift))
          lines = lines[0 .. 4] + [ " ..." ] if lines.length > 5
          temp_lines += lines.map{ |l| h(l) }
        end
      }
      temp_lines.join("<br/>\n")
    end

    def link_etc(binding, header, call, index)
      logger.debug("QS: link_etc #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'link-etc' do |binding|
          concat("Prblm,bnc,cty", binding)
        end
      else
        td binding, :class => 'link-etc' do |binding|
          div binding, :class => 'links' do |binding|
            a binding, :class => 'pmr-link', :href => url_for(call) do |binding|
              span binding, :style => "text-decoration: underline" do |binding|
                concat(call.pmr.pbc, binding)
              end
              popup binding do |binding|
                concat(qs_ecpaat_lines(call), binding)
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
      return "normal"
    end

    def owner(binding, header, call, index)
      logger.debug("QS: owner #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'owner not-editable' do |binding|
          width = Retain::Fields.field_width(:pmr_owner_name)
          concat("Owner".center(width).gsub(/ /, '&nbsp;'), binding)
        end
      else
        td binding, :class => "owner" do |binding|
          common_display_pmr_owner(binding, call)
        end
      end
    end

    def resolver(binding, header, call, index)
      logger.debug("QS: resolver #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'resolver not-editable' do |binding|
          width = Retain::Fields.field_width(:pmr_resolver_name)
          concat("Resolver".center(width).gsub(/ /, '&nbsp;'), binding)
        end
      else
        td binding, :class => "resolver" do |binding|
          common_display_pmr_resolver(binding, call)
        end
      end
    end
    
    def next_queue(binding, header, call, index)
      logger.debug("QS: next_queue #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => "next-queue not-editable" do |binding|
          width = (Retain::Fields.field_width(:next_queue) + 1 # +1 for commma
                   Retain::Fields.field_width(:h_or_s) + 1 +
                   Retain::Fields.field_width(:next_center))
          concat("Next Queue".center(width).gsub(/ /, '&nbsp;'), binding)
        end
      else
        td binding, :class => "next-queue" do |binding|
          common_display_pmr_next_queue(binding, call)
        end
      end
    end

    def pri_sev(binding, header, call, index)
      logger.debug("QS: pri_sev #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'pri-sev' do |binding|
          concat("P/S", binding)
        end
      else
        p = call.priority
        s = call.pmr.severity
        if p == s
          td_class =  "good"
          td_title = "Nothing wrong here"
        else
          td_class = "wag-wag"
          td_title = "Priority and Severity should match"
        end
        td_class << " pri-sev"
        td binding, :title => td_title, :class => td_class do |binding|
          concat("#{p}/#{s}", binding)
        end
      end
    end

    def age(binding, header, call, index)
      logger.debug("QS: age #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'age number' do |binding|
          concat("Age", binding)
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
        age_class << ' age'
        td(binding,
           :title => age_title,
           :class => age_class) do |binding|
          concat("#{age_value}", binding)
        end
      end
    end

    # Calculate the Jeff Smith days...
    MULT = [ 0, 10, 2, 0.5, 0.1 ]
    JEFF_TEXT = "Jeff Smith originated the concept of Severity Days. He was the " +
      "original level two manager of the AIX RS/6000 version 3 change team"
    SEV_TEXT = "Severity Days is the age of the PMR in days multiplied by a " +
      "factor based upon the current severity"
    def jeff(binding, header, call, index)
      logger.debug("QS: jeff #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'jeff number' do |binding|
          span binding, :title => JEFF_TEXT do |binding|
            concat("JS", binding)
          end
          concat("<br />", binding)
          span binding, :title => SEV_TEXT do |binding|
            concat("SevD", binding)
          end
        end
      else
        pmr = call.pmr
        jeff_days = (MULT[pmr.severity] * pmr.age).round
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
        jeff_class << " jeff"
        td binding, :class => jeff_class, :title => jeff_title do |binding|
          concat("#{jeff_days}", binding)
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
      logger.debug("ct_initial_response_requirement for #{call.to_param}")
      pmr = call.pmr
      customer = pmr.customer
      entry_time = call.center_entry_time
      if pmr.country == '000'       # U. S.
        logger.debug("initial response US")

        # Sev 1  System Down during Primeshift or Offshift: Initial
        #        customer callback - every effort should be made to
        #        contact customer within 1 hr
        if call.system_down
          logger.debug("system down")
          return entry_time + (1.to_r / 24) # clock hours
        end
        
        # Sev 1 Primeshift or Offshift: Initial customer callback is
        #       within 2 business hours, but try for one hour
        if pmr.severity == 1
          logger.debug("sev 1")
          return customer.business_hours(entry_time, 2)
        end
        
        # Sev 2,3,4 during Primeshift: Initial customer callback is
        #           within 2 business hours
        logger.debug("center is #{pmr.center.center}")
        logger.debug("entry time is #{entry_time}")
        if pmr.center.prime_shift(entry_time)
          logger.debug("prime_shift")
          return customer.business_hours(entry_time, 2)
        end
        
        # SEV 2,3,4 during Offshift: Initial customer callback is the
        #           next business day
        logger.debug("off shift")
        return customer.business_days(entry_time, 1)
      else
        logger.debug("initial response WT #{pmr.severity.class}")
        case pmr.severity
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
      raise "Did not figure out response time"
    end

    FOLLOW_UP_RESPONSE_TIME = [ 0, 1, 2, 5, 5 ] # business days

    def ct_normal_response_requirement(call)
      logger.debug("ct_normal_response_requirement for #{call.to_param}")
      pmr = call.pmr
      customer = pmr.customer
      days = FOLLOW_UP_RESPONSE_TIME[pmr.severity]
      start_time = pmr.last_ct_time
      logger.debug("TIME: ---- #{start_time}")
      customer.business_days(start_time, days)
    end

    def next_ct(binding, header, call, index)
      logger.debug("QS: next_ct #{call.nil? ? "header" : call.to_param}")
      if header
        th binding, :class => 'next-ct my-date' do |binding|
          concat("Next CT", binding)
        end
      else
        logger.debug("pmr's center is #{call.pmr.center.center}")
        is_initial = call.needs_initial_response?
        if is_initial
          nt = ct_initial_response_requirement(call)
        else
          nt = ct_normal_response_requirement(call)
        end
        
        last_ct_time = call.pmr.last_ct_time.new_offset(signon_user.tz)
        title = "Last CT: #{last_ct_time.strftime("%a, %d %b %Y %H:%M")}"
        
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
          concat(text, binding)
        end
      end
    end

    def duo(header, call, index)
      if header
        return th(:class => 'duo') do 
          "Customer".center(28).gsub(/ /, '&nbsp;') + "<br>" + "Comments"
        end
      end
      td :class => "duo" do
        customer_span(call) +
          "<br>" +
          comments_span(call)
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

    def comments_span(call)
      pmr = call.pmr
      span(:id => "comments_#{call.to_id}",
           :class => "edit-name click-to-edit",
           :title => "Click to Edit",
           :url => alter_combined_call_path(call)) do
        call.comments
      end
    end
    
    def popup(binding, hash = { })
      hash = { :class => "popup"}.merge(hash)
      span binding, :class => 'popup-wrapper' do
        span binding, hash do
          yield binding
        end
      end
    end

    [ :tr, :th, :td, :span, :div, :a, :table, :thead, :tbody, :tfoot ].each do |sym|
      eval("def #{sym}(binding, hash = { })
              @nesting ||= 0
              padding = \" \" * @nesting
              @nesting += 2
              concat(\"\#{padding}<#{sym}\#{hash.keys.map { |key| \" \#{key}='\#{hash[key]}'\"}}>\n\", binding)
              yield(binding)
              concat(\"\#{padding}</#{sym}>\n\", binding)
              @nesting -= 2
            end", nil, __FILE__, __LINE__ - 8)
    end

  end
end
