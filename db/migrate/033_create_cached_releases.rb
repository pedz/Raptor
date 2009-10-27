# -*- coding: utf-8 -*-

class CreateCachedReleases < ActiveRecord::Migration
  def self.up
    create_table :cached_releases do |t|
      t.integer :component_id, :null => false
      t.string  :release_name, :null => false, :limit => 3
      t.boolean :valid
      t.date    :start
      t.date    :end
      t.timestamps
    end
    execute "ALTER TABLE cached_releases ADD CONSTRAINT uq_cached_releases_tuple
             UNIQUE (component_id, release_name)"
    execute "ALTER TABLE cached_releases ADD CONSTRAINT fk_cached_releases_component_id
             FOREIGN KEY (component_id) REFERENCES cached_components(id)"
  end

  def self.down
    drop_table :cached_releases
  end
end
