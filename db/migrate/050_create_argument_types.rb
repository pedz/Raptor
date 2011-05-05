# -*- coding: utf-8 -*-
class CreateArgumentTypes < ActiveRecord::Migration
  def self.up
    create_table :argument_types do |t|
      t.string :name,      :null => false
      t.string :default,   :null => false
      t.integer :position, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :argument_types
  end
end
