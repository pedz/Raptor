# -*- coding: utf-8 -*-

class AddTimeZoneToCachedCall < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :customer_time_zone_adj, :integer
    add_column :cached_calls, :time_zone_code,         :integer
  end

  def self.down
    remove_column :cached_calls, :time_zone_code
    remove_column :cached_calls, :customer_time_zone_adj
  end
end
