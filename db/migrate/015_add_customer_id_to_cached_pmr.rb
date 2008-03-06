class AddCustomerIdToCachedPmr < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :customer_id, :integer, :null => false
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_customer_id
             FOREIGN KEY (customer_id) REFERENCES cached_customers(id)
             ON DELETE CASCADE"
  end

  def self.down
    execute "ALTER TABLE cached_pmrs DROP CONSTRAINT fk_cached_pmrs_customer_id"
    remove_column :cached_pmrs, :customer_id
  end
end
