class AddTimesToCachedRegistration < ActiveRecord::Migration
  def self.up
    add_column :cached_registrations, :daylight_savings_time, :boolean
    add_column :cached_registrations, :time_zone_adjustment, :integer
  end

  def self.down
    remove_column :cached_registrations, :time_zone_adjustment
    remove_column :cached_registrations, :daylight_savings_time
  end
end
