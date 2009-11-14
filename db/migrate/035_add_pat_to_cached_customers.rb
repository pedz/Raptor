class AddPatToCachedCustomers < ActiveRecord::Migration
  def self.up
    add_column :cached_customers, :pat, :boolean, :default => false
    execute "UPDATE cached_customers SET pat = false"
  end

  def self.down
    remove_column :cached_customers, :pat
  end
end
