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
