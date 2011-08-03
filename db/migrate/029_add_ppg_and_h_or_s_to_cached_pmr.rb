# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class AddPpgAndHOrSToCachedPmr < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :queue_name,  :string, :limit => 6
    add_column :cached_pmrs, :center_name, :string, :limit => 3
    add_column :cached_pmrs, :ppg,         :string, :limit => 3
    add_column :cached_pmrs, :h_or_s,      :string, :limit => 1
    add_column :cached_pmrs, :comments,    :string, :limit => 54
  end

  def self.down
    remove_column :cached_pmrs, :comments
    remove_column :cached_pmrs, :h_or_s
    remove_column :cached_pmrs, :ppg
    remove_column :cached_pmrs, :center_name
    remove_column :cached_pmrs, :queue_name
  end
end
