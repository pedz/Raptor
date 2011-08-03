# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.string  :name,     :null => false
      t.integer :owner_id, :null => false
      t.text    :code,     :null => false
      t.timestamps
    end
    execute "ALTER TABLE widgets ADD CONSTRAINT uq_widgets
             UNIQUE (name)"
    execute "ALTER TABLE widgets ADD CONSTRAINT fk_widgets_owner_id
             FOREIGN KEY (owner_id) REFERENCES users(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :widgets
  end
end
