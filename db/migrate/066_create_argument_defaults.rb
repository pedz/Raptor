class CreateArgumentDefaults < ActiveRecord::Migration
  def self.up
    create_table :argument_defaults do |t|
      t.integer :name_id, :null => false
      t.integer :argument_position, :null => false
      t.string :default, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :argument_defaults
  end
end
