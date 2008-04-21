require 'time'

module Retain
  module QsHelper

    DISP_LIST_1 = [ :call_button, :link_etc, :p_s_b, :pri_sev, :duo,
                    :owner, :resolver, :next_queue, :age, :jeff,
                    :next_ct, :ct ]

    HELP_TEXT = <<-EOF
	<tr>
	  <th colspan='10'>
	    Click on column headings to sort by that column
	  </th>
	</tr>
      EOF

    # The "1" style of header and body is the original version
    def display_qs_headers_1
      HELP_TEXT + tr { DISP_LIST_1.map { |sym| self.send sym, true, nil, nil }.join("\n") }
    end

    def display_qs_body_1
      ret = ""
      @queue.calls.each_with_index do |call, index|
        ret << tr do 
          DISP_LIST_1.map { |sym| self.send sym, false, call, index }.join("\n")
        end
      end
      ret
    end

    def duo(header, call, index)
      return "<th>Customer<br>Comments</th>" if header
      td do
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

    def customer(header, call, index)
      return "<th>Customer</th>" if header
      pmr = call.pmr
      if (mail = pmr.problem_e_mail.strip).blank?
        td :title => "No email given" do
          call.nls_customer_name
        end
      else
        title = "Click to send email to #{mail}"
        href = "mailto:#{mail}?subject=#{pmr.pbc.upcase}"
        td :title => title do
          a :href => href do
            call.nls_customer_name
          end
        end
      end
    end

    def comments_span(call)
      pmr = call.pmr
      span(:id => "#{pmr.pbc}-comments",
           :class => "edit-name click-to-edit",
           :title => "Click to Edit",
           :url => alter_combined_call_path(call)) do
        call.comments
      end
    end

    def comments(header, call, index)
      return "<th>Comments</th>" if header
      td { call.comments }
    end

    def ct(header, call, index)
      return "<th>CT</th>" if header
      td { link_to_remote("ct", :url => ct_combined_call_path(call)) }
    end
    
    def call_button(header, call, index)
      return "<th>Sel#</th>" if header
      td { button_url(index + 1, call) }
    end

    def p_s_b(header, call, index)
      return "<th>S</th>" if header
      td { call.p_s_b }
    end
    
    def cust_email(header, call, index)
      return "<th>Email Customer</th>" if header
      pmr = call.pmr
      if (mail = pmr.problem_e_mail.strip).blank?
        td do
          "No Email Given"
        end
      else
        href = "mailto:#{mail}?subject=#{pmr.pbc.upcase}"
        td do
          a :href => href do
            mail
          end
        end
      end
    end

    def qs_ecpaat_lines(call)
      pmr = call.pmr
      temp_hash = pmr.ecpaat
      n = DateTime.now.new_offset(pmr.customer.tz)
      
      temp_lines = [ "<span class='ecpaat-heading'>Customer: </span>" +
                     "#{call.nls_customer_name}" ]
      temp_lines << [ "<span class='ecpaat-heading'>Comments: </span>" +
                     "#{call.comments}" ]
      temp_lines << [ "<span class='ecpaat-heading'>Customer Time of Day: </span>" +
                      "#{n.strftime("%a, %d %b %Y %H:%M")}" ]
      Cached::Pmr::ECPAAT_HEADINGS.each { |heading|
        unless (lines = temp_hash[heading]).nil?
          temp_lines << ("<span class='ecpaat-heading'>" +
                         heading + ": " + "</span>" +
                         lines.shift)
          lines = lines[0 .. 4] + [ " ..." ] if lines.length > 5
          temp_lines += lines
        end
      }
      temp_lines.join("<br/>\n")
    end

    def link_etc(header, call, index)
      return "<th>Prblm,bnc,cty</th>" if header
      popup_text = popup do
        qs_ecpaat_lines(call)
      end
      text = span(:style => "text-decoration: underline;") do
        call.pmr.pbc
      end + popup_text
      td do
        div :class => "links" do
          link_to text, call, :class => 'pmr-link'
        end
      end
    end

    # Returns a class for the call row based upon the call
    def call_class(call)
      return "system-down" if call.system_down
      return "initial-response" if call.needs_initial_response?
      return "normal"
    end
    
    def owner(header, call, index)
      return "<th>Owner</th>" if header
      retid = Logon.instance.signon
      pmr = call.pmr
      name = pmr.owner.name
      if name.blank?
        name = "blank"
      end
      css_class, title, editable = call.validate_owner(signon_user)
      td do
        if editable
          span(:id => "#{pmr.pbc}-pmr_owner_id",
               :class => "collection-edit-name click-to-edit-button",
               :url => alter_combined_call_path(call),
               :options => {
                 :loadCollectionURL => owner_list_combined_registration_path(retid)
               }.to_json ) do
            title += ": Click to Edit"
            span :class => css_class, :title => title  do
              "#{name}"
            end
          end
        else
          span :class => css_class, :title => title  do
            "#{name}"
          end
        end
      end
    end

    def resolver(header, call, index)
      return "<th>Resolver</th>" if header
      retid = Logon.instance.signon
      pmr = call.pmr
      name = pmr.resolver.name
      if name.blank?
        name = "blank"
      end
      css_class, title, editable = call.validate_resolver(signon_user)
      td do
        if editable
          span(:id => "#{pmr.pbc}-pmr_resolver_id",
               :class => "collection-edit-name click-to-edit-button",
               :url => alter_combined_call_path(call),
               :options => {
                 :loadCollectionURL => owner_list_combined_registration_path(retid)
               }.to_json ) do
            title += ": Click to Edit"
            span :class => css_class, :title => title  do
              "#{name}"
            end
          end
        else
          span :class => css_class, :title => title  do
            "#{name}"
          end
        end
      end
    end

    def pri_sev(header, call, index)
      return "<th>P/S</th>" if header
      p = call.priority
      s = call.pmr.severity
      if p == s
        td_class =  "good"
        td_title = "Nothing wrong here"
      else
        td_class = "wag-wag"
        td_title = "Priority and Severity should match"
      end
      
      td :title => td_title, :class => td_class do
        "#{p}/#{s}"
      end
    end
    
    def next_queue(header, call, index)
      return "<th>Next Queue</th>" if header
      pmr = call.pmr
      nq_text = pmr.next_queue.nil? ? "" : pmr.next_queue.to_param
      css_class, title, editable = call.validate_next_queue(signon_user)
      td do
        if editable
          span(:id => "#{pmr.pbc}-next_queue",
               :class => "collection-edit-name click-to-edit-button",
               :url => alter_combined_call_path(call),
               :options => {
                 :loadCollectionURL => queue_list_combined_call_path(call)
               }.to_json ) do
            title += ": Click to Edit"
            span :class => css_class, :title => title  do
              nq_text
            end
          end
        else
          span :class => css_class, :title => title  do
            nq_text
          end
        end
      end
    end

    def age(header, call, index)
      return "<th>Age</th>" if header
      age_value = call.pmr.age.round
      if age_value > 100
        age_class = "wag-wag"
        age_title = "Over 100 days old"
      else
        age_class = "normal"
        age_title = "Young pup"
      end
      td(:title => age_title,
         :class => age_class,
         :style => "text-align: right") do
        "#{age_value}"
      end
    end

    # Calculate the Jeff Smith days...
    MULT = [ 0, 10, 2, 0.5, 0.1 ]
    JEFF_TEXT = "Jeff Smith originated the concept of Severity Days. He was the " +
      "original level two manager of the AIX RS/6000 version 3 change team"
    SEV_TEXT = "Severity Days is the age of the PMR in days multiplied by a " +
      "factor based upon the current severity"
    def jeff(header, call, index)
      return <<-EOF if header
          <th>
	    <span title='#{JEFF_TEXT}'>JS</span><br>
	    <span title='#{SEV_TEXT}'>SevD</span>
	  </th>
        EOF
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
      jeff_class = jeff_days > 300 ? "wag-wag" : (jeff_days > 50 ? "warn" : "normal")
      td :class => jeff_class, :title => jeff_title do
        "#{jeff_days}"
      end
    end

    def last_ct(call)
      last_ct_time = call.pmr.last_ct_time.new_offset(signon_user.tz)
      td do
        "#{last_ct_time.strftime("%a, %d %b %Y %H:%M")}"
      end
    end

    def cust_tod(call)
      # Current Time in customer's time zone
      n = DateTime.now.new_offset(call.pmr.customer.tz)
      td do
        "#{n.strftime("%a, %d %b %Y %H:%M")}"
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
      pmr = call.pmr
      customer = pmr.customer
      days = FOLLOW_UP_RESPONSE_TIME[pmr.severity]
      start_time = pmr.last_ct_time
      logger.debug("TIME: ---- #{start_time}")
      customer.business_days(start_time, days)
    end

    def next_ct(header, call, index)
      return "<th>Next CT</th>" if header
      logger.debug("pmr's center is #{call.pmr.center}")
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
        text = nt.new_offset(signon_user.tz).strftime("%a, %d %b %Y %H:%M")
        now += 1
        if now > nt
          css_class = "warn"
        else
          css_class = "normal"
        end
      end
      td :class => css_class, :title => title do
        text
      end
    end

    def tr(hash = { })
      logger.debug("In TR HEY!!!")
      "<tr#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</tr>"
    end
    
    def td(hash = { })
      "<td#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</td>"
    end
    
    def span(hash = { })
      "<span#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</span>"
    end
    
    def popup(hash = { })
      hash = { :class => "popup"}.merge(hash)
      "<div class='popup-wrapper'>" +
      "<span#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</span>" +
      "</div>"
    end
    
    def div(hash = { })
      "<div#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</div>"
    end
    
    def a(hash = { })
      "<a#{hash.keys.map { |key| " #{key}='#{hash[key]}'"}}>" +
      yield +
      "</a>"
    end
  end
end
