class CreateCachedCalls < ActiveRecord::Migration
  def self.up
    create_table :cached_calls do |t|
      t.string :queue_name, :null => false, :limit => 6
      t.string :center,     :null => false, :limit => 3
      t.string :h_or_s,     :null => false, :limit => 1, :default => 'S'
      t.string :ppg,        :null => false, :limit => 3
      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_calls
  end
end
