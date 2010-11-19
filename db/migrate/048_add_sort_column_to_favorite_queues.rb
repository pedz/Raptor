class AddSortColumnToFavoriteQueues < ActiveRecord::Migration
  def self.up
    # Add a column which will be altered via drag and drop.  Once
    # sorted, they will go from 0 up to N-1 where N is the number of
    # favorites a retuser has.
    add_column :favorite_queues, :sort_column, :integer

    # We start by setting the sort column to the id
    execute "UPDATE favorite_queues SET sort_column = id"

    # When we add, the sort column is also set to the id so it will be
    # at the bottom of the list.
    execute "ALTER TABLE favorite_queues ALTER COLUMN sort_column 
               SET DEFAULT currval('favorite_queues_id_seq'::regclass)"

    # Now we mark it NOT NULL cause I'm a good boy.
    execute "ALTER TABLE favorite_queues ALTER COLUMN sort_column SET NOT NULL"
  end

  def self.down
    remove_column :favorite_queues, :sort_column
  end
end
