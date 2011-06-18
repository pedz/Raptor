# -*- coding: utf-8 -*-
class CreateRetainNodeSelectors < ActiveRecord::Migration
  def self.up
    create_table :retain_node_selectors do |t|
      t.string  :description
      t.integer :retain_node_id, :null => false
      t.timestamps
    end
    execute "ALTER TABLE retain_node_selectors
             ADD CONSTRAINT fk_rns_retain_node_id
             FOREIGN KEY (retain_node_id) REFERENCES retain_nodes(id)
             ON DELETE CASCADE"
    #
    # The default for the retuser model for the software and hardware
    # retain node selectors assumes that the first of these has id of
    # 0 and the second has id of 1.
    #
    RetainNode.find(:first, :conditions => { :node => "bdc", :port => 3381 }).
      retain_node_selectors.create({ :description => "Default software node for Austin Teams" })
    RetainNode.find(:first, :conditions => { :node => "sf2", :port => 3581 }).
      retain_node_selectors.create({ :description => "Default hardware node for Austin Teams" })
    RetainNode.find(:first, :conditions => { :node => "rs4", :port => 3291 }).
      retain_node_selectors.create({ :description => "Default software node for EMEA Teams" })
    RetainNode.find(:first, :conditions => { :node => "ral", :port => 3181 }).
      retain_node_selectors.create({ :description => "Default hardware node for EMEA Teams" })
    #
    # Selectors to test nodes
    #
    RetainNode.find(:first, :conditions => { :node => "bdc", :port => 3301 }).
      retain_node_selectors.create({ :description => "Default TEST software node for Austin Teams" })
    RetainNode.find(:first, :conditions => { :node => "sf2", :port => 3501 }).
      retain_node_selectors.create({ :description => "Default TEST hardware node for Austin Teams" })
    RetainNode.find(:first, :conditions => { :node => "rs4", :port => 7301 }).
      retain_node_selectors.create({ :description => "Default TEST software node for EMEA Teams" })
    RetainNode.find(:first, :conditions => { :node => "ral", :port => 3102 }).
      retain_node_selectors.create({ :description => "Default TEST hardware node for EMEA Teams" })
  end

  def self.down
    drop_table :retain_node_selectors
  end
end
