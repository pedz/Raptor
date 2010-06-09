#
# Migration to add fields we need so that the user can pick which node
# to use.  There are parts needed:
#
# 1. The user record needs a boolean flag called 'test' that can be
# set which will put the user into test mode and thus access the
# APPTEST set of retain servers.
#
# 2. The retuser record needs a 'test' boolean flag too to denote if
# the user id (in particular the password) is for the APPTEST servers
# or the real servers.  A retain id for the APPTEST can be the same id
# but the passwords are different.
#
# 3. The reuser record needs a 3-tuple of node, host, and port.  This
# is slightly redundant since node and port will tell you which host
# and host plus port will tell you which node.  But I'm going to keep
# all three.
#
class NodeSelect < ActiveRecord::Migration
  def self.up
    add_column :users,    :test, :boolean
    add_column :retusers, :test, :boolean
    add_column :retusers, :host, :string
    add_column :retusers, :node, :string
    add_column :retusers, :port, :integer
    #
    # A user can now have two retain ids: one for normal and one for test.
    #
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_user_id";
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_user_id UNIQUE (user_id, test)"
    #
    # Also, the same retain id can be used twice: once for normal
    # access and once for test access.
    #
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_retid"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_retid UNIQUE (retid, test)"
  end

  def self.down
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_user_id"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_user_id UNIQUE (user_id)"
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_retid"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_retid UNIQUE (retid)"
    remove_column :users,    :test
    remove_column :retusers, :test
    remove_column :retusers, :host
    remove_column :retusers, :node
    remove_column :retusers, :port
  end
end
