class CreateConditions < ActiveRecord::Migration
  def self.up
    create_table :conditions do |t|
      t.integer :name_id, :null => false
      t.string :sql, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :conditions
  end
end
