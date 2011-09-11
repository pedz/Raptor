# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateUseCounters < ActiveRecord::Migration
  def self.up
    create_table :use_counters do |t|
      t.integer :user_id, :null => false
      t.string :name,     :null => false
      t.integer :count
      t.timestamps
    end
    execute "ALTER TABLE use_counters ADD CONSTRAINT fk_use_counters_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :use_counters
  end
end
