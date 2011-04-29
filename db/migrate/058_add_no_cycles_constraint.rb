class AddNoCyclesConstraint < ActiveRecord::Migration
  def self.up
    execute "
      ALTER TABLE relationships
      ADD CONSTRAINT no_cycles_check
      CHECK (no_cycles(container_name_id, element_name_id, element_name_type));"
  end

  def self.down
  end
end
