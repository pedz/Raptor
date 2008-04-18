class AddDirtyBits < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :dirty, :boolean
    add_column :cached_calls, :dirty, :boolean
  end

  def self.down
    remove_column :cached_calls, :dirty
    remove_column :cached_pmrs, :dirty
  end
end
