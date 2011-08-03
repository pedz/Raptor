# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.string :abstract
      t.integer :priority, :default => 3
      t.integer :ftype, :default => 0
      t.integer :state, :default => 0
      t.timestamps 
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
