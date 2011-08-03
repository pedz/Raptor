# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
class AddProblemStatusCodeToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :problem_status_code, :string
  end

  def self.down
    remove_column :cached_pmrs, :problem_status_code
  end
end
