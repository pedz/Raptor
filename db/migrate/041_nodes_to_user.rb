class NodesToUser < ActiveRecord::Migration
  def self.up
    add_column :retusers, :hardware_node, :string,  :default => 'ral'
    add_column :retusers, :software_node, :string,  :default => 'bdc'
    add_column :retusers, :apptest,       :boolean, :default => false
  end

  def self.down
    remove_column :retusers, :hardware_node
    remove_column :retusers, :software_node
    remove_column :retusers, :apptest
  end
end
