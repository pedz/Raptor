# -*- coding: utf-8 -*-
class ChangeRetuserLogonFields < ActiveRecord::Migration
  def self.up
    rename_column :retusers, :return_value, :logon_return
    rename_column :retusers, :reason,       :logon_reason
  end

  def self.down
    rename_column :retusers, :logon_return, :return_value
    rename_column :retusers, :logon_reason,  :reason
  end
end
