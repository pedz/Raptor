class CreateCachedCustomers < ActiveRecord::Migration
  def self.up
    create_table :cached_customers do |t|
      t.string  :country,         :limit => 3,  :null => false
      t.string  :customer_number, :limit => 7,  :null => false
      t.string  :company_name ,   :limit => 36, :null => false
      t.string  :center,          :limit => 3,  :null => false
      t.boolean :daylight_time_flag
      t.string  :time_zone,       :limit => 5
      t.integer :time_zone_binary
      t.timestamps
    end
    execute "ALTER TABLE cached_customers ADD CONSTRAINT uq_cached_customers
             UNIQUE (country, customer_number)"
  end

  def self.down
    drop_table :cached_customers
  end
end
