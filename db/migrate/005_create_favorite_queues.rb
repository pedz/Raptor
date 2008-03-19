# A user can set up a list of queues that he will visit often.  This
# table stores those queues.
#
# +user_id+::    +integer+ -- Points to the user record
# +queue_id+::   +integer+ -- Points to queue
#
class CreateFavoriteQueues < ActiveRecord::Migration
  def self.up
    create_table :favorite_queues do |t|
      t.integer :user_id,  :null => false
      t.integer :queue_id, :null => false
      t.timestamps 
    end
    execute "ALTER TABLE favorite_queues ADD CONSTRAINT uq_favorite_queues
             UNIQUE (user_id, queue_id)"
    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_user_id
             FOREIGN KEY (user_id) REFERENCES users(id)"
    execute "ALTER TABLE favorite_queues ADD CONSTRAINT fk_favorite_queue_queue_id
             FOREIGN KEY (queue_id) REFERENCES cached_queues(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :favorite_queues
  end
end
