class CreateRetainNodeSelectors < ActiveRecord::Migration
  def self.up
    create_table :retain_node_selectors do |t|
      t.string :description
      t.integer :retain_node_id

      t.timestamps
    end
  end

  def self.down
    drop_table :retain_node_selectors
  end
end
