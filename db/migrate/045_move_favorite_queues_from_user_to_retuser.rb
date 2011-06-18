# -*- coding: utf-8 -*-
class MoveFavoriteQueuesFromUserToRetuser < ActiveRecord::Migration
  def self.up
    # We first add a retuser_id column.  Note that NULL is allowed temporarily.
    add_column :favorite_queues, :retuser_id, :integer

    # Now set it to the proper values.
    execute "UPDATE favorite_queues 
             SET retuser_id = ( SELECT users.current_retuser_id
                                FROM users
                                WHERE users.id = favorite_queues.user_id );"
    
    # Now create the foreign key constraint and make the column not null
    execute "ALTER TABLE favorite_queues
             ADD CONSTRAINT fk_favorite_queue_retuser_id
             FOREIGN KEY (retuser_id) REFERENCES retusers(id)"
    execute "ALTER TABLE favorite_queues
             ALTER COLUMN retuser_id SET NOT NULL"

    # Now remove the user_id column and its constraint
    execute "ALTER TABLE favorite_queues DROP CONSTRAINT fk_favorite_queue_user_id"
    remove_column :favorite_queues, :user_id
  end

  def self.down
    # Add user column back and set it.
    add_column :favorite_queues, :user_id, :integer

    # Set the value of user_id correctly.
    execute "UPDATE favorite_queues 
             SET user_id = ( SELECT retusers.user_id
                             FROM retusers
                             WHERE retusers.id = favorite_queues.retuser_id );"

    # Now add in the proper foreign key constraints and not null constraint.
    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE favorite_queues
             ALTER COLUMN user_id SET NOT NULL"
    
    # Now, back out the retuser_id foreign key and constraint
    execute "ALTER TABLE favorite_queues
             DROP CONSTRAINT fk_favorite_queue_retuser_id"
    remove_column :favorite_queues, :retuser_id
  end
end
