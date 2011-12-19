class AddConstraintOnCachedPmrPrimary < ActiveRecord::Migration
  def self.up
    execute "UPDATE cached_pmrs SET \"primary\" = NULL
             WHERE \"primary\" NOT IN ( SELECT id FROM cached_calls );"
    execute "ALTER TABLE cached_pmrs ADD CONSTRAINT fk_cached_pmrs_primary
             FOREIGN KEY (\"primary\") REFERENCES cached_calls(id)
             ON DELETE SET NULL"
  end

  def self.down
    execute "ALTER TABLE cached_pmrs DROP CONSTRAINT fk_cached_pmrs_primary"
  end
end
