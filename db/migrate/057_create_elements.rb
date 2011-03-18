class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.integer :widget_id, :null => false
      t.integer :view_id, :null => false
      t.integer :owner_id, :null => false
      t.integer :row, :null => false
      t.integer :col, :null => false
      t.integer :rowspan, :default => 1
      t.integer :colspan, :default => 1
      t.timestamps
    end
    execute "ALTER TABLE elements ADD CONSTRAINT uq_elements
             UNIQUE (view_id,row,col)"
    execute "ALTER TABLE elements ADD CONSTRAINT fk_elements_owner_id
             FOREIGN KEY (owner_id) REFERENCES users(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE elements ADD CONSTRAINT fk_elements_widget_id
             FOREIGN KEY (widget_id) REFERENCES widgets(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE elements ADD CONSTRAINT fk_elements_view_id
             FOREIGN KEY (view_id) REFERENCES views(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :elements
  end
end
