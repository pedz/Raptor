class MakeCreationDateNonNullInCachedPmr < ActiveRecord::Migration
  def self.up
    execute "UPDATE cached_pmrs SET creation_date = 'UNKNOWN' WHERE creation_date IS NULL"
    execute "ALTER TABLE cached_pmrs ALTER COLUMN creation_date SET NOT NULL"
  end

  def self.down
    execute "ALTER TABLE cached_pmrs ALTER COLUMN creation_date DROP NOT NULL"
  end
end
