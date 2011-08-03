# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateCachedQueueInfos < ActiveRecord::Migration
  def self.up
    create_table :cached_queue_infos do |t|
      t.integer :queue_id, :null => false
      t.integer :owner_id, :null => false
      t.timestamps 
    end
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT uq_cached_queue_infos_queue_owner
             UNIQUE (queue_id, owner_id)"
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT fk_cached_queue_infos_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_queue_infos ADD CONSTRAINT fk_cached_queue_infos_owner_id
             FOREIGN KEY (owner_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :cached_queue_infos
  end
end
