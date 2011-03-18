class CreateViews < ActiveRecord::Migration
  def self.up
    create_table :views do |t|
      t.string :name, :null => false
      t.integer :owner_id, :null => false
      t.timestamps
    end
    execute "ALTER TABLE views ADD CONSTRAINT uq_views
             UNIQUE (name)"
    execute "ALTER TABLE views ADD CONSTRAINT fk_views_owner_id
             FOREIGN KEY (owner_id) REFERENCES users(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :views
  end
end
