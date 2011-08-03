# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class AddAbsorbedQueueListToCachedCenters < ActiveRecord::Migration
  def self.up
    add_column :cached_centers, :absorbed_queue_list, :string
  end

  def self.down
    remove_column :cached_centers, :absorbed_queue_list
  end
end
