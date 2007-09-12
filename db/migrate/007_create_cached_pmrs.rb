class CreateCachedPmrs < ActiveRecord::Migration
  def self.up
    create_table :cached_pmrs do |t|
      t.string :problem, :null => false, :limit => 5
      t.string :branch,  :null => false, :limit => 3
      t.string :country, :null => false, :limit => 3
      t.timestamps 
    end
  end

  def self.down
    drop_table :cached_pmrs
  end
end
