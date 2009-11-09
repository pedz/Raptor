class AddSeverityToCachedCalls < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :severity, :integer
  end

  def self.down
    remove_column :cached_calls, :severity
  end
end
