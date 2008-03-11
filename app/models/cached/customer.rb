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
      to_combined.time_zone_binary.to_r / (24 * 60)
    end
    once :tz

  end
end
