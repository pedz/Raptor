class CreateRotationAssignments < ActiveRecord::Migration
  def self.up
    create_table :rotation_assignments do |t|
      t.integer     :rotation_group_id, :null => false
      t.string      :pmr,               :null => false, :default => ''
      t.integer     :assigned_by,       :null => false
      t.integer     :assigned_to,       :null => false
      t.integer     :rotation_type_id,  :null => false
      t.text        :notes,             :null => false, :default => ''
      t.timestamps
    end
    execute "ALTER TABLE rotation_assignments ADD CONSTRAINT fk_rotation_assignments_rotation_group_id
             FOREIGN KEY (rotation_group_id) REFERENCES rotation_groups(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE rotation_assignments ADD CONSTRAINT fk_rotation_assignments_assigned_by
             FOREIGN KEY (assigned_by) REFERENCES users(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE rotation_assignments ADD CONSTRAINT fk_rotation_assignments_assigned_to
             FOREIGN KEY (assigned_to) REFERENCES users(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE rotation_assignments ADD CONSTRAINT fk_rotation_assignments_rotation_type_id
             FOREIGN KEY (rotation_type_id) REFERENCES rotation_types(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :rotation_assignments
  end
end
