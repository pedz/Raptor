# -*- coding: utf-8 -*-

module Cached
  # === Retain Customer Model
  #
  # This model is the database cached version of a Retain customer.
  # The database table is <em>cached_customers</em>.  One of the main
  # purposes of this model is to calculate customer based times.
  class Customer < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: country
    # The country that the customer is based in.

    ##
    # :attr: customer_number
    # The customer's number.  This is somewhat the Retain key for this
    # model.

    ##
    # :attr: center_id
    # The center that the customer is in.

    ##
    # :attr: company_name
    # The company name for the customer.

    ##
    # :attr: daylight_time_flag
    # A boolean if the customer observes daylight savings time.

    ##
    # :attr: time_zone
    # The timezone for the customer.

    ##
    # :attr: time_zone_binary
    # A different representation of the timezone for the customer.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: pat
    # A boolean that is set to true if the customer is a premium
    # support customer.

    set_table_name "cached_customers"

    ##
    # :attr: center
    # A belongs_to association to the Cached::Center that this
    # customer belongs to.
    belongs_to :center, :class_name => "Cached::Center"

    ##
    # :attr: pmrs
    # A has_many association to the Cached::Pmr entries for this
    # customer.
    has_many   :pmrs,   :class_name => "Cached::Pmr"
    
    ##
    # A short cut method to find or create a customer given the
    # country and customer number.
    def self.f_or_i_by_cntry_and_cust(cntry, cnum)
      find_or_initialize_by_country_and_customer_number(cntry, cnum)
    end
    
    ##
    # Customer Time Zone as a rational fraction of a day
    def tz
      # logger.debug("CHC: customer tz called from #{caller.join("\n")}")
      if tzb = time_zone_binary
        tzb.to_r / MINS_PER_DAY
      else
        nil
      end
    end
    once :tz

    private
    
    MINS_PER_HOUR = 60.to_r
    HOURS_PER_DAY = 24.to_r
    MINS_PER_DAY = HOURS_PER_DAY * MINS_PER_HOUR
    WORK_HOURS = 8 ... 17       # 8 a.m. to 5 p.m. (but not including 5 p.m.)
    WORK_DAYS =  1 .. 5         # Monday thru Friday

    ##
    # Returns true if argument is within the customer's normal
    # business hours.
    def during_business?(t)
      # NOTE! The === operator is not symetric for ranges
      # logger.debug("TIME: during_business? #{t.hour} #{t.wday} = #{(WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)}")
      (WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)
    end
  end
end
