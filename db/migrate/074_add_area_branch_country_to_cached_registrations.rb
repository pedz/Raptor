class AddAreaBranchCountryToCachedRegistrations < ActiveRecord::Migration
  def self.up
    add_column :cached_registrations, :area_number, :string, :limit => 2
    add_column :cached_registrations, :branch,      :string, :limit => 3
    add_column :cached_registrations, :country,     :string, :limit => 3
  end

  def self.down
    remove_column :cached_registrations, :country
    remove_column :cached_registrations, :branch
    remove_column :cached_registrations, :area_number
  end
end
