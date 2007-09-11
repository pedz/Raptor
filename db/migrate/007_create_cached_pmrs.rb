class CreateCachedPmrs < ActiveRecord::Migration
  def self.up
    create_table :cached_pmrs do |t|

      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_pmrs
  end
end
