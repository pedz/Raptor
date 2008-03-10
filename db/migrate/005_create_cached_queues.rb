class CreateCachedQueues < ActiveRecord::Migration
  def self.up
    create_table :cached_queues do |t|
      t.string :queue_name, :null => false, :limit => 6
      t.string :center,     :null => false, :limit => 3
      t.string :h_or_s,     :null => false, :limit => 1, :default => 'S'
      t.timestamps 
    end
    execute "ALTER TABLE cached_queues ADD CONSTRAINT uq_cached_queues_triple
             UNIQUE (queue_name, center, h_or_s)"
  end

  def self.down
    drop_table :cached_queues
  end
end
