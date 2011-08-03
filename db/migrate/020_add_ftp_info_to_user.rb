# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class AddFtpInfoToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :ftp_host, :string
    add_column :users, :ftp_login, :string
    add_column :users, :ftp_pass, :string
    add_column :users, :ftp_basedir, :string
  end

  def self.down
    remove_column :users, :ftp_basedir
    remove_column :users, :ftp_pass
    remove_column :users, :ftp_login
    remove_column :users, :ftp_host
  end
end
