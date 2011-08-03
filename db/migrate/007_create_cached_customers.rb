# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateCachedCustomers < ActiveRecord::Migration
  def self.up
    create_table :cached_customers do |t|
      t.string  :country,         :limit => 3, :null => false
      t.string  :customer_number, :limit => 7, :null => false
      t.integer :center_id
      t.string  :company_name ,   :limit => 36
      t.boolean :daylight_time_flag
      t.string  :time_zone,       :limit => 5
      t.integer :time_zone_binary
      t.timestamps
    end
    execute "ALTER TABLE cached_customers ADD CONSTRAINT uq_cached_customers_pair
             UNIQUE (country, customer_number)"
    execute "ALTER TABLE cached_customers ADD CONSTRAINT fk_cached_customers_center_id
             FOREIGN KEY (center_id) REFERENCES cached_centers(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :cached_customers
  end
end
