# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateArgumentTypes < ActiveRecord::Migration
  def self.up
    create_table :argument_types do |t|
      t.string  :name,     :null => false
      t.string  :default,  :null => false
      t.integer :position, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :argument_types
  end
end
