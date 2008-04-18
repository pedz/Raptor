class AddCallSearchResultToCachedCall < ActiveRecord::Migration
  def self.up
    add_column :cached_calls, :call_search_result, :binary
  end

  def self.down
    remove_column :cached_calls, :call_search_result
  end
end
