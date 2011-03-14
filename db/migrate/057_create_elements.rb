class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.integer :widgit_id
      t.integer :view_id
      t.integer :row
      t.integer :column
      t.integer :owner_id
      t.integer :rowspan
      t.integer :colspan

      t.timestamps
    end
  end

  def self.down
    drop_table :elements
  end
end
