# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateConditions < ActiveRecord::Migration
  def self.up
    create_table :conditions do |t|
      t.integer :name_id, :null => false
      t.string :sql, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :conditions
  end
end
