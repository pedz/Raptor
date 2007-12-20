class CreateQueueInfos < ActiveRecord::Migration
  def self.up
    create_table :queue_infos do |t|
      t.string :queue_name
      t.string :center
      t.string :owner

      t.timestamps 
    end
  end

  def self.down
    drop_table :queue_infos
  end
end
