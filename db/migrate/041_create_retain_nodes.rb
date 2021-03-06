# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateRetainNodes < ActiveRecord::Migration
  def self.up
    create_table :retain_nodes do |t|
      t.string :host
      t.string :node
      t.string :node_type
      t.string :description
      t.integer :port
      t.boolean :apptest
      t.integer :tunnel_offset
      t.timestamps
    end
  end

  def self.down
    drop_table :retain_nodes
  end
end
