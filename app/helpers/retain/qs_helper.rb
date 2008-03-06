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
      css_class, title, editable = call.validate_owner
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
      css_class, title, editable = call.validate_resolver
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

    def next_queue(call)
      pmr = call.pmr
      nq_text = pmr.next_queue + "," + pmr.next_center
      css_class, title, editable = call.validate_next_queue
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
        "#{call.pmr.last_ct_time.localtime.strftime("%a, %d %b %Y %H:%M")}"
      end
    end

    def cust_tod(call)
      # Local Time
      n = Time.now
      # Convert to GMT Time
      n -= Time.zone_offset(n.zone)
      # Convert to Customer Time
      n += call.pmr.customer.time_zone_binary * 60
      td do
        "#{n.strftime("%a, %d %b %Y %H:%M")}"
      end
    end

    US_PRIME_INITIAL_RESPONSE_TIME = [ 0, 2.hours, 2.hours, 2.hours, 2.hours ]

    def ct_initial_response_requirements(call)
      pmr = call.pmr
      country = pmr.country
      if country == '000'       # U. S.
        logger.debug("initial response US")
        if prime_shift(call)
          return US_PRIME_INITIAL_RESPONSE_TIME[pmr.severity.to_i]
        else
          if pmr.severity == 1
            return 2.hours
          else       # off shift initial response is next business day
            # return 1.business_day(country)
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

    def ct_requirement(call)
      if call.needs_initial_response?
        ct_initial_response_requirements(call)
      else
        FOLLOW_UP_RESPONSE_TIME[call.pmr.severity.to_i]
      end
    end

    def next_ct_time(call)
      ct_requirement(call) - (Time.now - call.pmr.last_ct_time)
    end

    def next_ct(call)
      nt = next_ct_time(call).to_i
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
