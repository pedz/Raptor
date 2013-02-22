class AddOpcToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :opc, :text
  end

  def self.down
    remove_column :cached_pmrs, :opc
  end
end
