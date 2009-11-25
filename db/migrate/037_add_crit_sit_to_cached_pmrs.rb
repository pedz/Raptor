class AddCritSitToCachedPmrs < ActiveRecord::Migration
  def self.up
    add_column :cached_pmrs, :problem_crit_sit, :string
  end

  def self.down
    remove_column :cached_pmrs, :problem_crit_sit
  end
end
