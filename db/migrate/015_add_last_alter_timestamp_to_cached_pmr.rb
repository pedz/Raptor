# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class AddLastAlterTimestampToCachedPmr < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :last_alter_timestamp, :binary
  end

  def self.down
    remove_column :cached_pmrs, :last_alter_timestamp
  end
end
