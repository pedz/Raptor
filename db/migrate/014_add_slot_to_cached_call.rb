# -*- coding: utf-8 -*-

class AddSlotToCachedCall < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :slot, :integer
  end

  def self.down
    remove_column :cached_calls, :slot
  end
end
