# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateCachedCenters < ActiveRecord::Migration
  def self.up
    create_table :cached_centers do |t|
      t.string  :center,                    :limit => 3, :null => false
      t.string  :software_center_mnemonic,  :limit => 3
      t.string  :center_daylight_time_flag, :limit => 1
      t.integer :delay_to_time
      t.integer :minutes_from_gmt
      t.timestamps
    end
    execute "ALTER TABLE cached_centers ADD CONSTRAINT uq_cached_centers
             UNIQUE (center)"
    execute "INSERT INTO cached_centers ( center, created_at, updated_at )
               VALUES ( 'nul', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP )"
  end

  def self.down
    drop_table :cached_centers
  end
end
