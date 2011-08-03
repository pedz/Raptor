# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class AddMatchPatternToWidget < ActiveRecord::Migration
  def self.up
    add_column :widgets, :match_pattern, :string, :null => false, :default => '.*'
  end

  def self.down
    remove_column :widgets, :match_pattern
  end
end
