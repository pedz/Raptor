# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateCachedCalls < ActiveRecord::Migration
  def self.up
    create_table :cached_calls do |t|
      t.integer :queue_id,          :null  => false
      t.string  :ppg,               :null  => false, :limit => 3
      t.integer :pmr_id,            :null  => false
      t.integer :priority
      t.string  :p_s_b,             :limit => 1
      t.string  :comments,          :limit => 54
      t.string  :nls_customer_name, :limit => 28
      t.string  :nls_contact_name,  :limit => 30
      t.string  :contact_phone_1,   :limit => 19
      t.string  :contact_phone_2,   :limit => 19
      t.string  :cstatus,           :limit => 7
      t.string  :category,          :limit => 3
      t.boolean :system_down
      t.timestamps 
    end
    execute "ALTER TABLE cached_calls ADD CONSTRAINT uq_cached_calls_pair
             UNIQUE (queue_id, ppg)"
    execute "ALTER TABLE cached_calls ADD CONSTRAINT fk_cached_calls_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_calls ADD CONSTRAINT fk_cached_calls_pmr_id
             FOREIGN KEY (pmr_id) REFERENCES cached_pmrs(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :cached_calls
  end
end
