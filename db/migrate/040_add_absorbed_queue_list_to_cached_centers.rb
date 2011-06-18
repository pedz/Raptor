# -*- coding: utf-8 -*-
class AddAbsorbedQueueListToCachedCenters < ActiveRecord::Migration
  def self.up
    add_column :cached_centers, :absorbed_queue_list, :string
  end

  def self.down
    remove_column :cached_centers, :absorbed_queue_list
  end
end
