class AddDeletedToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :deleted, :boolean, :default => false
    execute "UPDATE cached_pmrs SET deleted = false"
  end

  def self.down
    remove_column :cached_pmrs, :deleted
  end
end
