class CreateRotationGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :rotation_group_members do |t|
      t.integer :rotation_group_id, :null => false
      t.string :name,               :null => false
      t.integer :user_id,           :null => false
      t.boolean :active,            :null => false
      t.timestamps
    end
    execute "ALTER TABLE rotation_group_members ADD CONSTRAINT uq_rotation_group_members_name
             UNIQUE (rotation_group_id,name)"
    execute "ALTER TABLE rotation_group_members ADD CONSTRAINT uq_rotation_group_members_user
             UNIQUE (rotation_group_id,user_id)"
    execute "ALTER TABLE rotation_group_members ADD CONSTRAINT fk_rotation_group_members_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE rotation_group_members ADD CONSTRAINT fk_rotation_group_members_rotation_group_id
             FOREIGN KEY (rotation_group_id) REFERENCES rotation_groups(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :rotation_group_members
  end
end
