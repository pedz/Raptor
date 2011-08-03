# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class AddDeletedToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :deleted, :boolean, :default => false
    execute "UPDATE cached_pmrs SET deleted = false"
  end

  def self.down
    remove_column :cached_pmrs, :deleted
  end
end
