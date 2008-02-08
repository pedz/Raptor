class CreateQueueInfos < ActiveRecord::Migration
  def self.up
    create_table :queue_infos do |t|
      t.integer :queue_id, :null => false
      t.integer :owner_id, :null => false
      t.timestamps 
    end
  end

  def self.down
    drop_table :queue_infos
  end
end
