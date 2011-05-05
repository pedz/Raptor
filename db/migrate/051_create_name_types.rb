class CreateNameTypes < ActiveRecord::Migration
  def self.up
    create_table :name_types do |t|
      t.string  :name_type,        :null => false
      t.string  :table_name,       :null => false
      t.integer :argument_type_id, :null => false
      t.boolean :container,        :null => false, :default => false
      t.boolean :containable,      :null => false, :default => false
      t.timestamps
    end
    execute "ALTER TABLE name_types ADD CONSTRAINT uq_name_types_name UNIQUE (name_type)"
    execute "ALTER TABLE name_types ADD CONSTRAINT fk_argument_type
             FOREIGN KEY (argument_type_id) REFERENCES argument_types(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :name_types
  end
end
