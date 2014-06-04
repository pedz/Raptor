class CreateRotationTypes < ActiveRecord::Migration
  def self.up
    create_table :rotation_types do |t|
      t.integer     :rotation_group_id, :null => false
      t.string      :name,              :null => false
      t.boolean     :pmr_required,      :null => false
      t.text        :comments,          :null => false
      t.integer     :next_type_id,      :null => false
      t.timestamps
    end
    execute "ALTER TABLE rotation_types ADD CONSTRAINT uq_rotation_types_name
             UNIQUE (rotation_group_id,name)"
    execute "ALTER TABLE rotation_types ADD CONSTRAINT fk_rotation_types_rotation_group_id
             FOREIGN KEY (rotation_group_id) REFERENCES rotation_groups(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE rotation_types ADD CONSTRAINT fk_rotation_types_next_type_id
             FOREIGN KEY (next_type_id) REFERENCES rotation_types(id)
             ON DELETE CASCADE"
    execute "INSERT INTO rotation_types ( rotation_group_id, name, pmr_required, comments, next_type_id )
             VALUES ( (select id from rotation_groups where name = 'Null'),
                      '#{RotationType::NO_OP_NAME}', false, 'Used as a null value for the next_type_id column', 1 )"
    execute "INSERT INTO rotation_types ( rotation_group_id, name, pmr_required, comments, next_type_id )
             VALUES ( (select id from rotation_groups where name = 'Null'),
                      '#{RotationType::AUTO_SKIP_NAME}', false, 'Used when filling in assignments', 2 )"
  end
  
  def self.down
    drop_table :rotation_types
  end
end
