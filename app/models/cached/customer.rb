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
      if tzb = to_combined.time_zone_binary
        tzb.to_r / MINS_PER_DAY
      else
        nil
      end
    end
    once :tz

    def business_days(start_time, days)
      business_minutes(start_time, days * MINS_PER_WORK_DAY)
    end

    def business_hours(start_time, hours)
      business_minutes(start_time, hours * MINS_PER_HOUR)
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

    def business_minutes(start_time, minutes)
      local_tz = tz || 0
      cust_time = cust_start_time = start_time.new_offset(local_tz)
      # Move clock forward by minutes until we hit the start of a new
      # hour
      while minutes > 0 && cust_time.min != 0
        logger.debug("TIME: #{cust_time} #{minutes} minute")
        minutes -= 1 if during_business?(cust_time)
        cust_time += ONE_MINUTE
      end

      # Move clock forward by hours until we hit the start of a new
      # work day
      while minutes >= MINS_PER_HOUR && cust_time.hour != WORK_HOURS.first
        logger.debug("TIME: #{cust_time} #{minutes } hour")
        minutes -= MINS_PER_HOUR if during_business?(cust_time)
        cust_time += ONE_HOUR
      end

      # Now move the clock forward by days until was have less than a
      # day
      while minutes >= MINS_PER_WORK_DAY
        logger.debug("TIME: #{cust_time} #{minutes} day")
        minutes -= MINS_PER_WORK_DAY if during_business?(cust_time)
        cust_time += ONE_DAY
      end

      # If we hit exactly 0 minutes at this point, that means that we
      # need to back up to the end of the customer's business day.  We
      # know that cust_time.minutes is 0.  We back up a minute (to
      # 59), then back up hours until we hit business time, then move
      # forward the minute we took off at the start.
      if minutes == 0
        cust_time -= ONE_MINUTE
        until during_business?(cust_time)
          cust_time -= ONE_HOUR
        end
        cust_time += ONE_MINUTE
      end

      # Now move the clock forward by hours until was have less than
      # an hour
      while minutes >= MINS_PER_HOUR
        logger.debug("TIME: #{cust_time} #{minutes} last hours")
        minutes -= MINS_PER_HOUR if during_business?(cust_time)
        cust_time += ONE_HOUR
      end

      # Now move the clock forward by minutes until was have less than
      # a minute
      while minutes > 0
        logger.debug("TIME: #{cust_time} #{minutes} last minutes")
        minutes -= 1 if during_business?(cust_time)
        cust_time += ONE_MINUTE
      end
      start_time + (cust_time - cust_start_time)
    end
    
    def during_business?(t)
      # NOTE! The === operator is not symetric for ranges
      logger.debug("TIME: during_business? #{t.hour} #{t.wday} = #{(WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)}")
      (WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)
    end
  end
end
