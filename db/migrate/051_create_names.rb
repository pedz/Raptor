class CreateNames < ActiveRecord::Migration
  def self.up
    create_table :names do |t|
      t.string  :type,     :null => false
      t.string  :name,     :null => false
      t.integer :owner_id, :null => false
      t.timestamps
    end
    # The purpose of this table is to have a set of unique names
    # amoung the different models.
    execute "ALTER TABLE names ADD CONSTRAINT uq_teams_name UNIQUE (name)"

    # The type is restricted and we don't want to delete the type and
    # have all of the names for that type deleted.  That seems like an
    # accident waiting to happen.  Thus we set ON DELETE to NO ACTION
    # (which is the default but I wanted to make it clear that this
    # was a conscious choice.
    execute "ALTER TABLE names ADD CONSTRAINT fk_teams_type
             FOREIGN KEY (type) REFERENCES name_types(name_type)
             ON DELETE NO ACTION"

    execute "ALTER TABLE names ADD CONSTRAINT fk_names_owner_id
             FOREIGN KEY (owner_id) REFERENCES users(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :names
  end
end
