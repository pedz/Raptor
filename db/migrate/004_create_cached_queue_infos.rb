class CreateCachedQueueInfos < ActiveRecord::Migration
  def self.up
    create_table :cached_queue_infos do |t|
      t.integer :queue_id, :null => false
      t.integer :owner_id, :null => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_queue_infos
  end
end
