class AddNoCyclesConstraint < ActiveRecord::Migration
  def self.up
    execute "
      ALTER TABLE relationships
      ADD CONSTRAINT no_cycles_check
      CHECK (no_cycles(container_name_id, item_id, item_type));"
  end

  def self.down
    execute "
      ALTER TABLE relationships
      DROP CONSTRAINT no_cycles_check;"
  end
end
