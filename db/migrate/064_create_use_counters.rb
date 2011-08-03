# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateUseCounters < ActiveRecord::Migration
  def self.up
    create_table :use_counters do |t|
      t.integer :user_id
      t.string :name
      t.integer :count

      t.timestamps
    end
  end

  def self.down
    drop_table :use_counters
  end
end
