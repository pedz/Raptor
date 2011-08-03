# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class CreateAssociationTypes < ActiveRecord::Migration
  def self.up
    create_table :association_types do |t|
      t.string :association_type, :null => false
      t.timestamps
    end
    execute "ALTER TABLE association_types ADD CONSTRAINT uq_association_type UNIQUE (association_type)"
  end

  def self.down
    drop_table :association_types
  end
end
