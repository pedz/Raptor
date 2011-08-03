# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class AddSeverityToCachedCalls < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :severity, :integer
  end

  def self.down
    remove_column :cached_calls, :severity
  end
end
