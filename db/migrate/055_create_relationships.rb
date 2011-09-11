# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :container_name_id,    :null => false
      t.integer :relationship_type_id, :null => false
      t.integer :item_id,              :null => false
      t.string  :item_type,            :null => false
      t.timestamps
    end
    execute "ALTER TABLE relationships ADD CONSTRAINT uq_relationship_tuple UNIQUE
             (container_name_id, item_id, item_type)"
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationships_container_name
             FOREIGN KEY (container_name_id) REFERENCES names(id)
             ON DELETE NO ACTION"
    execute "ALTER TABLE relationships ADD CONSTRAINT fk_relationships_relationship_type
             FOREIGN KEY (relationship_type_id) REFERENCES relationship_types(id)
             ON DELETE NO ACTION"
  end

  def self.down
    drop_table :relationships
  end
end
