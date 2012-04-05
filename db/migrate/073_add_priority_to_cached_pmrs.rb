class AddPriorityToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :priority, :integer
  end

  def self.down
    remove_column :cached_pmrs, :priority
  end
end
