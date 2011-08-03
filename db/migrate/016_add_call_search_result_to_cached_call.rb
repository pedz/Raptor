# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class AddCallSearchResultToCachedCall < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :call_search_result, :binary
  end

  def self.down
    remove_column :cached_calls, :call_search_result
  end
end
