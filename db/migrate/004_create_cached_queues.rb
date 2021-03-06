# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateCachedQueues < ActiveRecord::Migration
  def self.up
    create_table :cached_queues do |t|
      t.string  :queue_name, :null => false, :limit => 6
      t.string  :h_or_s,     :null => false, :limit => 1
      t.integer :center_id,  :null => false
      t.timestamps 
    end
    execute "ALTER TABLE cached_queues ADD CONSTRAINT uq_cached_queues_triple
             UNIQUE (queue_name, h_or_s, center_id)"
    execute "ALTER TABLE cached_queues ADD CONSTRAINT fk_cached_queues_center_id
             FOREIGN KEY (center_id) REFERENCES cached_centers(id)
             ON DELETE CASCADE"
    execute "INSERT INTO cached_queues ( queue_name, h_or_s, center_id, created_at, updated_at )
               VALUES ( 'nullqu', 'h', (select id from cached_centers where center = 'nul'), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP )"
  end

  def self.down
    drop_table :cached_queues
  end
end
