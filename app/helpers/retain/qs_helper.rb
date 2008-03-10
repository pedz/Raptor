require 'time'

module Retain
  module QsHelper
    def owner(call)
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
               :class => "edit-name click-to-edit",
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

    def resolver(call)
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
               :class => "edit-name click-to-edit",
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

    def pri_sev(call)
      p = call.priority
      s = call.pmr.severity
      td_class = p == s ? "good" : "wag-wag"
      td :class => td_class do
        "#{p}/#{s}"
      end
    end
    
    def next_queue(call)
      pmr = call.pmr
      nq_text = pmr.next_queue + "," + pmr.next_center
      css_class, title, editable = call.validate_next_queue(signon_user)
      td do
        if editable
          span(:id => "#{pmr.pbc}-next_queue",
               :class => "edit-name click-to-edit",
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

    def age(call)
      td :style => "text-align: right" do
        "#{call.pmr.age.round}"
      end
    end

    # Calculate the Jeff Smith days...
    MULT = [ 0, 10, 2, 0.5, 0.1 ]
    def jeff(call)
      pmr = call.pmr
      td :style => "text-align: right" do 
        "#{(MULT[pmr.severity.to_i] * pmr.age).round}"
      end
    end

    def last_ct(call)
      td do
        "#{call.pmr.last_ct_time.strftime("%a, %d %b %Y %H:%M")}"
      end
    end

    def cust_tod(call)
      # Current Time in customer's time zone
      n = DateTime.now.new_offset(call.pmr.customer.tz)
      td do
        "#{n.strftime("%a, %d %b %Y %H:%M")}"
      end
    end

    # True if call queued to center during its prime time.
    def prime_shift(time)
      # 8 a.m. to 5 p.m. Monday thru Friday
      t = time
      t.hour === (8 .. 17) && t.wday === (1 .. 5)
    end

    # Return the UTC time of the next business day in the given time
    # zone... how am I going to do this?
    def start_next_bus_day(time, tz)
      their_time = time + tz
    end

    def ct_initial_response_requirement(call)
      pmr = call.pmr
      cust = pmr.customer
      # time_zone_binary is in minutes; tz will be in seconds
      tz = cust.time_zone_binary * 60
      entry_time = call.center_entry_time
      if pmr.country == '000'       # U. S.
        logger.debug("initial response US")
        if prime_shift(entry_time)
          return entry_time + 2.hours
        else
          if pmr.severity == 1
            return entry_time + 2.hours
          else       # off shift initial response is next business day
            # return 1.business_day(country)
            new_time = next_bus_day(entry_time)
            return 1.day
          end
        end
      else                      # WT
        logger.debug("initial response WT #{pmr.severity.class}")
        case pmr.severity.to_i
        when 1
          # 2.business_hours(country)
          2.hours
        when 2
          # 4.business_hours(country)
          4.hours
        when 3
          # 8.business_hours(country)
          8.hours
        when 4
          # 8.business_hours(country)
          8.hours
        else
          raise "Invalid PMR severity"
        end
      end
    end

    FOLLOW_UP_RESPONSE_TIME = [ 0, 1.day, 2.days, 5.days, 5.days ]

    def ct_normal_response_requirement(call)
      FOLLOW_UP_RESPONSE_TIME[call.pmr.severity.to_i]
    end

    def ct_requirement(call)
      if call.needs_initial_response?
        ct_initial_response_requirement(call)
      else
        ct_normal_response_requirement(call)
      end
    end

    def next_ct_time(call)
      ct_requirement(call) - (DateTime.now - call.pmr.last_ct_time)
    end

    def next_ct(call)
      logger.debug("pmr's center is #{call.pmr.center}")
      is_initial = call.needs_initial_response?
      if is_initial
        nt = ct_initial_response_requirement(call)
      else
        nt = next_ct_time(call).to_i
      end

      if nt <= 0
        text = "CT Overdue"
        css_class = "wag-wag"
      else
        nt /= (60 * 60)
        text = "#{(nt / 24).truncate} days and #{(nt % 24).truncate} hours"
        css_class = "good"
      end
      td :class => css_class do
        text
      end
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
  end
end
