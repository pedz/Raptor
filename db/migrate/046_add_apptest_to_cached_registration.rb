class AddApptestToCachedRegistration < ActiveRecord::Migration
  def self.up
    add_column :cached_registrations, :apptest, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :cached_registrations, :apptest
  end
end
