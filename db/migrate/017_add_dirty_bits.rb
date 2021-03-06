# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class AddDirtyBits < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :dirty, :boolean
    add_column :cached_calls, :dirty, :boolean
    add_column :cached_queues, :dirty, :boolean
  end

  def self.down
    remove_column :cached_queues, :dirty
    remove_column :cached_calls, :dirty
    remove_column :cached_pmrs, :dirty
  end
end
