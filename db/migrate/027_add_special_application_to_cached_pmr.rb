# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class AddSpecialApplicationToCachedPmr < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :special_application, :string, :limit => 1
  end

  def self.down
    remove_column :cached_pmrs, :special_application
  end
end
