class CreateCachedCalls < ActiveRecord::Migration
  def self.up
    create_table :cached_calls do |t|
      t.integer :queue_id,      :null  => false
      t.string  :queue_name,    :null  => false, :limit => 6
      t.string  :center,        :null  => false, :limit => 3
      t.string  :h_or_s,        :null  => false, :limit => 1, :default => 'S'
      t.string  :ppg,           :null  => false, :limit => 3
      t.string  :problem,       :limit => 5
      t.string  :branch,        :limit => 3
      t.string  :country,       :limit => 3
      t.string  :priority,      :limit => 1
      t.string  :p_s_b,         :limit => 1
      t.string  :comments,      :limit => 54
      t.string  :customer_name, :limit => 28
      t.string  :cstatus,       :limit => 7
      t.string  :category,      :limit => 3
      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_calls
  end
end
