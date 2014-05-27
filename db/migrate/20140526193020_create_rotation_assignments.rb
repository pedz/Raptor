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
  end

  def self.down
    drop_table :rotation_assignments
  end
end
