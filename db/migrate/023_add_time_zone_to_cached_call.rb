# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

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
