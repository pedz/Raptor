# -*- coding: utf-8 -*-

class AddSpecialApplicationToCachedPmr < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :special_application, :string, :limit => 1
  end

  def self.down
    remove_column :cached_pmrs, :special_application
  end
end
