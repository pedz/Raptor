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
    add_column :users,    :current_retuser_id, :integer # Allow nulls :-(
    add_column :retusers, :apptest,            :boolean, :default => false, :null => false
    add_column :retusers, :software_node_id,   :integer, :default => 1,     :null => false
    add_column :retusers, :hardware_node_id,   :integer, :default => 2,     :null => false

    #
    # The same user can have multiple retain ids.
    #
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_user_id";

    #
    # Also, the same retain id can be used by multiple people -- it
    # might get confuseing.
    #
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_retid"

    #
    # But, a user can have only one retain id + apptest.  I.e. there
    # is no reason for the same user to have the same retain id except
    # if apptest differs.
    #
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_tuple UNIQUE (user_id, retid, apptest)"

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

    #
    # Also, make sure that current_retuser_id points into the retuser
    # table.  If / when the retuser entry is deleted, we will set
    # current_retuser_id to null.
    #
    execute "ALTER TABLE retusers ADD CONSTRAINT uq_id_user_id UNIQUE (id, user_id)"
    execute "ALTER TABLE users
             ADD CONSTRAINT fk_users_current_retuser_id
             FOREIGN KEY (current_retuser_id, id) REFERENCES retusers(id, user_id)"

    #
    # Now, we set the current_retuser_id to the user's only retuser
    # entry if they have one.
    #
    execute "UPDATE users AS u
             SET current_retuser_id = r.id
             FROM retusers r
             WHERE u.id = r.user_id;"
  end

  def self.down
    # but constraint of one user and one retain user id back in place.
    execute "ALTER TABLE users    DROP CONSTRAINT fk_users_current_retuser_id"
    execute "ALTER TABLE retusers DROP CONSTRAINT uq_id_user_id"
    
    execute "ALTER TABLE retusers DROP CONSTRAINT fk_retusers_hardware_node_id"
    execute "ALTER TABLE retusers DROP CONSTRAINT fk_retusers_software_node_id"

    execute "ALTER TABLE retusers DROP CONSTRAINT uq_retusers_tuple"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_user_id UNIQUE (user_id)"
    execute "ALTER TABLE retusers ADD  CONSTRAINT uq_retusers_retid UNIQUE (retid)"

    remove_column :retusers, :apptest
    remove_column :retusers, :software_node_id
    remove_column :retusers, :hardware_node_id
    remove_column :users,    :current_retuser_id
  end
end
