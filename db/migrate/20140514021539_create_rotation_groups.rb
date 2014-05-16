class CreateRotationGroups < ActiveRecord::Migration
  def self.up
    create_table :rotation_groups do |t|
      t.string :name, :null => false
      t.timestamps
    end
    execute "ALTER TABLE rotation_groups ADD CONSTRAINT uq_name UNIQUE (name)"
  end

  def self.down
    drop_table :rotation_groups
  end
end
