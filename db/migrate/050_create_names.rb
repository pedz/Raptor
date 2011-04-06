class CreateNames < ActiveRecord::Migration
  def self.up
    create_table :names do |t|
      t.string :type, :null => false
      t.string :name, :null => false
      t.timestamps
    end
    execute "ALTER TABLE names ADD CONSTRAINT uq_teams_name UNIQUE (name)"
  end

  def self.down
    drop_table :names
  end
end
