# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'active_record/fixtures'

class AddRetainNodes < ActiveRecord::Migration
  def self.up
    down
    #
    # We preload the list of Retain nodes that we know about as of
    # June 11, 2010.
    #
    y = YAML.load(File.open(Rails.root.join("config", "saved", "node-list"))).each do |node|
      node.symbolize_keys!
      RetainNode.create(node)
    end
  end

  def self.down
    RetainNode.delete_all
  end
end
