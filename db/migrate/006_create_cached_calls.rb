class CreateCachedCalls < ActiveRecord::Migration
  def self.up
    create_table :cached_calls do |t|

      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_calls
  end
end
