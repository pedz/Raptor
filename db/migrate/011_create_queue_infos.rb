class CreateQueueInfos < ActiveRecord::Migration
  def self.up
    create_table :queue_infos do |t|
      t.string :queue_name, :null => false, :limit => 6
      t.string :center, :null => false, :limit => 3
      t.string :owner, :null => false, :limit => 6
      t.timestamps 
    end
  end

  def self.down
    drop_table :queue_infos
  end
end
