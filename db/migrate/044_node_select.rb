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
# 3. The retuser record needs two pointers to retain node selectors:
# one for software and one for hardware.  Generally, these will point
# to "default" selectors so that the admin can switch the node that
# most Raptor users go to in the case that the node goes down.  But
# they can be set by each user.  In particular, the EMEA teams will
# probably set it to the default EMEA selector.
#
class NodeSelect < ActiveRecord::Migration
  def self.up
    add_column :users,    :test_mode,        :boolean, :default => false, :null => false
    add_column :retusers, :test_mode,        :boolean, :default => false, :null => false
    add_column :retusers, :software_node_id, :integer, :default => 1,     :null => false
    add_column :retusers, :hardware_node_id, :integer, :default => 2,     :null => false
    #
    # A user can now have two retain ids: one for normal and one for test.
    #
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_user_id";
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_user_id UNIQUE (user_id, test_mode)"
    #
    # Also, the same retain id can be used twice: once for normal
    # access and once for test access.
    #
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_retid"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_retid UNIQUE (retid, test_mode)"
    #
    # Create foreign key constraints for software_node and
    # hardware_node
    #
    execute "ALTER TABLE retusers
             ADD CONSTRAINT fk_retusers_software_node_id
             FOREIGN KEY (software_node_id) REFERENCES retain_node_selectors(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE retusers
             ADD CONSTRAINT fk_retusers_hardware_node_id
             FOREIGN KEY (hardware_node_id) REFERENCES retain_node_selectors(id)
             ON DELETE CASCADE"
  end

  def self.down
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_user_id"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_user_id UNIQUE (user_id)"
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_retid"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_retid UNIQUE (retid)"
    remove_column :users,    :test_mode
    remove_column :retusers, :test_mode
  end
end
