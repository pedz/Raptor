module Cached
  class Customer < Base
    set_table_name "cached_customers"

    has_many :pmrs, :class_name => "Cached::Pmr"
    
    def self.f_or_i_by_cntry_and_cust(cntry, cnum)
      find_or_initialize_by_country_and_customer_number(cntry, cnum)
    end
  end
end
