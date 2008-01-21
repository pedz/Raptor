class CreateCachedCalls < ActiveRecord::Migration
  def self.up
    create_table :cached_calls do |t|
      t.integer :queue_id,          :null  => false
      t.string  :ppg,               :null  => false, :limit => 3
      t.integer :pmr_id,            :null  => false
      t.string  :priority,          :limit => 1
      t.string  :p_s_b,             :limit => 1
      t.string  :comments,          :limit => 54
      t.string  :nls_customer_name, :limit => 28
      t.string  :nls_contact_name,  :limit => 30
      t.string  :contact_phone_1,   :limit => 19
      t.string  :contact_phone_2,   :limit => 19
      t.string  :cstatus,           :limit => 7
      t.string  :category,          :limit => 3
      t.timestamps 
    end
    execute("ALTER TABLE cached_calls ADD CONSTRAINT unique_calls UNIQUE " +
            "(queue_id, ppg)")
  end

  def self.down
    drop_table :cached_calls
  end
end
