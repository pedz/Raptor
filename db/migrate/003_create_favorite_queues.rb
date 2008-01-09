# A user can set up a list of queues that he will visit often.  This
# table stores those queues.
#
# +user_id+::    +integer+ -- Points back to the user record
# +queue_name+:: +string+  -- Retain queue name
# +center+::     +string+  -- Retain center
# +h_or_s+::     +string+  -- Software (S) or Hardware (H)
#
class CreateFavoriteQueues < ActiveRecord::Migration
  def self.up
    create_table :favorite_queues do |t|
      t.integer :user_id,    :null => false
      t.string  :queue_name, :null => false, :limit => 6
      t.string  :center,     :null => false, :limit => 3
      t.string  :h_or_s, :default => 'S'
      t.timestamps 
    end
  end

  def self.down
    drop_table :favorite_queues
  end
end
