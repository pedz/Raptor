# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateArgumentDefaults < ActiveRecord::Migration
  def self.up
    create_table :argument_defaults do |t|
      t.integer :name_id, :null => false
      t.integer :argument_position, :null => false
      t.string :default, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :argument_defaults
  end
end
