# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateCachedComponents < ActiveRecord::Migration
  def self.up
    create_table :cached_components do |t|
      t.string  :short_component_id,         :limit => 11, :null => false
      t.string  :component_name,             :limit => 19, :null => false
      t.string  :multiple_change_team_id,    :limit => 6, :null => false
      t.string  :multiple_fe_support_grp_id, :limit => 6, :null => false
      t.boolean :valid
      t.timestamps
    end
    execute "ALTER TABLE cached_components ADD CONSTRAINT uq_cached_components_tuple
             UNIQUE (short_component_id)"
  end

  def self.down
    drop_table :cached_components
  end
end
