class AddLastFetchedTimestamp < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :last_fetched, :datetime
    add_column :cached_calls, :last_fetched, :datetime
    add_column :cached_queues, :last_fetched, :datetime
    execute "update cached_pmrs set last_fetched = updated_at"
    execute "update cached_calls set last_fetched = updated_at"
    execute "update cached_queues set last_fetched = updated_at"
  end

  def self.down
    remove_column :cached_queues, :last_fetched
    remove_column :cached_calls, :last_fetched
    remove_column :cached_pmrs, :last_fetched
  end
end
