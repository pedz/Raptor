class AddHotToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :hot, :boolean, :default => false
    add_column :cached_pmrs, :business_justification, :string
    execute "UPDATE cached_pmrs SET hot = false"
  end

  def self.down
    remove_column :cached_pmrs, :business_justification
    remove_column :cached_pmrs, :hot
  end
end