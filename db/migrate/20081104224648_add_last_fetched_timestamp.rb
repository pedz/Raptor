class AddLastFetchedTimestamp < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :last_fetched, :datetime
    add_column :cached_calls, :last_fetched, :datetime
    add_column :cached_queues, :last_fetched, :datetime
  end

  def self.down
    remove_column :cached_queues, :last_fetched
    remove_column :cached_calls, :last_fetched
    remove_column :cached_pmrs, :last_fetched
  end
end
