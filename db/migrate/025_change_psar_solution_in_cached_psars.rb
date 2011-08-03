# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class ChangePsarSolutionInCachedPsars < ActiveRecord::Migration
  def self.up
    rename_column :cached_psars, :psar_solution, :psar_solution_code
  end

  def self.down
    rename_column :cached_psars, :psar_solution_code, :psar_solution
  end
end
