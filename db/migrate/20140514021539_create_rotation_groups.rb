class CreateRotationGroups < ActiveRecord::Migration
  def self.up
    create_table :rotation_groups do |t|
      t.string      :name,     :null => false
      t.integer     :queue_id, :null => false
      t.timestamps
    end
    execute "ALTER TABLE rotation_groups ADD CONSTRAINT uq_name UNIQUE (name)"
    execute "ALTER TABLE rotation_groups ADD CONSTRAINT fk_rotation_groups_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
    execute "INSERT INTO rotation_groups ( name, queue_id, created_at, updated_at )
              VALUES ( 'Null', (select id from cached_queues where queue_name = 'nullqu'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP )"
  end

  def self.down
    drop_table :rotation_groups
  end
end
