# -*- coding: utf-8 -*-

module Cached
  class Customer < Base
    set_table_name "cached_customers"

    belongs_to :center, :class_name => "Cached::Center"
    has_many   :pmrs,   :class_name => "Cached::Pmr"
    
    def self.f_or_i_by_cntry_and_cust(cntry, cnum)
      find_or_initialize_by_country_and_customer_number(cntry, cnum)
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

    private
    
    WORK_HOURS = 8 ... 17       # 8 a.m. to 5 p.m. (but not including 5 p.m.)
    WORK_DAYS =  1 .. 5         # Monday thru Friday

    def during_business?(t)
      # NOTE! The === operator is not symetric for ranges
      # logger.debug("TIME: during_business? #{t.hour} #{t.wday} = #{(WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)}")
      (WORK_HOURS === t.hour) && (WORK_DAYS === t.wday)
    end
  end
end
