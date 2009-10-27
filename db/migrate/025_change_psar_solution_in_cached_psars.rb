# -*- coding: utf-8 -*-

class ChangePsarSolutionInCachedPsars < ActiveRecord::Migration
  def self.up
    rename_column :cached_psars, :psar_solution, :psar_solution_code
  end

  def self.down
    rename_column :cached_psars, :psar_solution_code, :psar_solution
  end
end
