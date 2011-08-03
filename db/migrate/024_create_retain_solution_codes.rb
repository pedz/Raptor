# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class CreateRetainSolutionCodes < ActiveRecord::Migration
  def self.up
    create_table :retain_solution_codes do |t|
      t.integer :psar_solution_code
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :retain_solution_codes
  end
end
