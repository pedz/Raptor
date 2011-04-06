class CreateNameTypes < ActiveRecord::Migration
  def self.up
    create_table :name_types do |t|
      t.string :type
      t.timestamps
    end
    execute "ALTER TABLE name_types ADD CONSTRAINT uq_teams_name UNIQUE (type)"
  end

  def self.down
    drop_table :name_types
  end
end
