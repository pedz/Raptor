require 'time'

module Retain
  module QsHelper
    # Returns a class for the call row based upon the call
    def call_class(call)
      return "system-down" if call.system_down
      return "initial-response" if call.needs_initial_response?
      return "normal"
    end
    
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
      nq_text = pmr.next_queue.nil? ? "" : pmr.next_queue.to_param
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
      jeff_days = (MULT[pmr.severity] * pmr.age).round
      jeff_class = jeff_days > 300 ? "wag-wag" : (jeff_days > 50 ? "warn" : "normal")
      td :class => jeff_class do
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
        if pmr.center.prime_shift(entry_time)
          logger.debug("prime_shift")
          return customer.business_hours(entry_time, 2)
        end
        
        # SEV 2,3,4 during Offshift: Initial customer callback is the
        #           next business day
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

    def next_ct(call)
      logger.debug("pmr's center is #{call.pmr.center}")
      is_initial = call.needs_initial_response?
      if is_initial
        nt = ct_initial_response_requirement(call)
      else
        nt = ct_normal_response_requirement(call)
      end

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
