class CreateArgumentTypes < ActiveRecord::Migration
  def self.up
    create_table :argument_types do |t|
      t.string :name
      t.string :default

      t.timestamps
    end
  end

  def self.down
    drop_table :argument_types
  end
end
