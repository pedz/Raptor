class CreateNameTypes < ActiveRecord::Migration
  def self.up
    create_table :name_types do |t|
      t.string :name_type,    :null => false
      t.boolean :container,   :null => false, :default => false
      t.boolean :containable, :null => false, :default => false
      t.timestamps
    end
    execute "ALTER TABLE name_types ADD CONSTRAINT uq_team_types_name UNIQUE (name_type)"
  end

  def self.down
    drop_table :name_types
  end
end
