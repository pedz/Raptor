class AddForeignKeysToPsars < ActiveRecord::Migration
  def self.up
    execute "UPDATE cached_psars SET pmr_id = null WHERE pmr_id IS NOT NULL AND pmr_id NOT IN ( SELECT id FROM cached_pmrs );"
    # We specify NO ACTION here.  If a PMR is in the system and have
    # text and we delete it, thats kinda ok.  But if we have PSARs
    # attached, I'd like to stop the delete.  Really... this exercise
    # is trying to figure out why PMRs are being deleted in the first
    # place.  They should never be deleted.
    execute "ALTER TABLE cached_psars ADD CONSTRAINT fk_cached_psars_pmr_id
             FOREIGN KEY (pmr_id) REFERENCES cached_pmrs(id)
             ON DELETE NO ACTION"
  end

  def self.down
    execute "ALTER TABLE cached_psars DROP CONSTRAINT fk_cached_psars_pmr_id"
  end
end
