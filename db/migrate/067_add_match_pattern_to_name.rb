class AddMatchPatternToName < ActiveRecord::Migration
  def self.up
    add_column :names, :match_pattern, :string, :null => false, :default => '.*'
  end

  def self.down
    remove_column :names, :match_pattern
  end
end
