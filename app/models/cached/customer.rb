# -*- coding: utf-8 -*-

module Cached
  class Customer < Base
    set_table_name "cached_customers"

    belongs_to :center, :class_name => "Cached::Center"
    has_many   :pmrs,   :class_name => "Cached::Pmr"
    
    def self.f_or_i_by_cntry_and_cust(cntry, cnum)
      find_or_initialize_by_country_and_customer_number(cntry, cnum)
    end
    
    # Customer Time Zone as a rational fraction of a day
    def tz
      logger.debug("CHC: customer tz called from #{caller.join("\n")}")
      if tzb = to_combined.time_zone_binary
        tzb.to_r / MINS_PER_DAY
      else
        nil
      end
    end
    once :tz

    def old_business_days(start_time, days)
      old_business_minutes(start_time, days * MINS_PER_WORK_DAY)
    end

    def old_business_hours(start_time, hours)
      old_business_minutes(start_time, hours * MINS_PER_HOUR)
    end

    A1 = Array.new(24 * 14, 0)
    A2 = Array.new(24 * 14, 0)
    
    (0 .. 1).each do |week|
      week_index = week * 7 * 24
      # From Sun midnight to Monday morning
      (0 .. 31).each { |hr|
        A1[week_index + hr] = 24 +  8 - hr
        A2[week_index + hr] = 24 + 24
      }
      # For Tue - Fri morning
      (2 .. 5).each { |day|
        (0 .. 7).each { |hr|
          A1[week_index + day * 24 + hr] =  8 - hr
          A2[week_index + day * 24 + hr] = 15 + 24 + 24
        }
      }
      # For Mon - Thu evening
      (1 .. 4).each { |day|
        (17 .. 23).each { |hr|
          A1[week_index + day * 24 + hr] =  8 + 24 - hr
          A2[week_index + day * 24 + hr] = 15
        }
      }
      # For Fri evening
      (5 .. 5).each { |day|
        (17 .. 23).each { |hr|
          A1[week_index + day * 24 + hr] = 17 + 15 + 24 + 24 - hr
          A2[week_index + day * 24 + hr] = 15 + 24 + 24
        }
      }
      # Saturday 
      (0 .. 23).each { |hr|
        A1[week_index + 6 * 24 + hr] = 24 + 24 + 8 - hr
        A2[week_index + 6 * 24 + hr] = 24 + 24
      }
    end

    def business_days(start_time, days)
      local_tz = tz || 0
      cust_time = start_time.new_offset(local_tz)
      start_i1 = cust_time.wday * 24 + cust_time.hour
      i1 = start_i1 + A1[start_i1] + (days * 24)
      i1 += A2[i1]
      start_time + (i1 - start_i1).hours
    end

    def business_hours(start_time, hours)
      local_tz = tz || 0
      cust_time = start_time.new_offset(local_tz)
      start_i1 = cust_time.wday * 24 + cust_time.hour
      i1 = start_i1 + A1[start_i1] + hours
      i1 += A2[i1]
      start_time + (i1 - start_i1).hours
    end

    JIM = Array.new(3 * 24 * 7, 0)
    
    (0 .. 2).each { |week|
      (1 .. 5).each { |day|
        (8 .. 16).each { |hour|
          JIM[(week * 7 + day) * 24 + hour] = 1
        }
      }
    }

    def jims_business_days(start_time, days)
      local_tz = tz || 0
      cust_time = cust_start_time = start_time.new_offset(local_tz)
      i1 = start_i1 = (cust_time.wday * 24 + cust_time.hour)
      stomp_on_mins = false
      until JIM[i1] == 1
        i1 += 1
        stomp_on_mins = true
      end
      until days == 0
        i1 += 24
        days -= JIM[i1]
      end
      if stomp_on_mins
        start_time -= start_time.min.minutes
      end
      start_time + (i1 - start_i1).hours
    end

    def jims_business_hours(start_time, hours)
      local_tz = tz || 0
      cust_time = start_time.new_offset(local_tz)
      i1 = start_i1 = (cust_time.wday * 24 + cust_time.hour)
      stomp_on_mins = false
      until JIM[i1] == 1
        i1 += 1
        stomp_on_mins = true
      end
      until hours == 0
        i1 += 1
        hours -= JIM[i1]
      end
      if stomp_on_mins
        start_time -= start_time.min.minutes
      end
      start_time + (i1 - start_i1).hours
    end

    private
    
    MINS_PER_HOUR = 60.to_r
    HOURS_PER_DAY = 24.to_r
    MINS_PER_DAY = HOURS_PER_DAY * MINS_PER_HOUR
    ONE_DAY = 1.to_r
    ONE_HOUR = ONE_DAY / HOURS_PER_DAY
    ONE_MINUTE = ONE_DAY / MINS_PER_DAY
    WORK_HOURS = 8 ... 17       # 8 a.m. to 5 p.m. (but not including 5 p.m.)
    WORK_DAYS =  1 .. 5         # Monday thru Friday
    HOURS_PER_WORK_DAY = WORK_HOURS.last - WORK_HOURS.first
    MINS_PER_WORK_DAY = HOURS_PER_WORK_DAY * MINS_PER_HOUR

    def old_business_minutes(start_time, minutes)
      # logger.debug("start_time class is #{start_time.class}")
      local_tz = tz || 0
      cust_time = cust_start_time = start_time.new_offset(local_tz)
      # Move clock forward by minutes until we hit the start of a new
      # hour
      while minutes > 0 && cust_time.min != 0
        # logger.debug("TIME: #{cust_time} #{minutes} minute")
        minutes -= 1 if during_business?(cust_time)
        cust_time += ONE_MINUTE
      end

      # Move clock forward by hours until we hit the start of a new
      # work day
      while minutes >= MINS_PER_HOUR && cust_time.hour != WORK_HOURS.first
        # logger.debug("TIME: #{cust_time} #{minutes } hour")
        minutes -= MINS_PER_HOUR if during_business?(cust_time)
        cust_time += ONE_HOUR
      end

      # Now move the clock forward by days until was have less than a
      # day
      while minutes >= MINS_PER_WORK_DAY
        # logger.debug("TIME: #{cust_time} #{minutes} day")
        minutes -= MINS_PER_WORK_DAY if during_business?(cust_time)
        cust_time += ONE_DAY
      end

      # If we hit exactly 0 minutes at this point, that means that we
      # need to go forward to the start of the customer's business
      # day.
      if minutes == 0
        cust_time += ONE_MINUTE
        until during_business?(cust_time)
          cust_time += ONE_HOUR
        end
        cust_time -= ONE_MINUTE
      end

      # Now move the clock forward by hours until was have less than
      # an hour
      while minutes >= MINS_PER_HOUR
        # logger.debug("TIME: #{cust_time} #{minutes} last hours")
        minutes -= MINS_PER_HOUR if during_business?(cust_time)
        cust_time += ONE_HOUR
      end

      # Now move the clock forward by minutes until was have less than
      # a minute
      while minutes > 0
        # logger.debug("TIME: #{cust_time} #{minutes} last minutes")
        minutes -= 1 if during_business?(cust_time)
        cust_time += ONE_MINUTE
      end
      start_time + (cust_time - cust_start_time)
    end
    
    def during_business?(t)
      # NOTE! The === operator is not symetric for ranges
      # logger.debug("TIME: during_business? #{t.hour} #{t.wday} = #{(WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)}")
      (WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)
    end
  end
end
