# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateConditions < ActiveRecord::Migration
  def self.up
    create_table :conditions do |t|
      t.integer :name_id, :null => false
      t.string  :sql,     :null => false
      t.timestamps
    end
    execute "ALTER TABLE conditions ADD CONSTRAINT fk_conditions_name_id
             FOREIGN KEY (name_id) REFERENCES names(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :conditions
  end
end
