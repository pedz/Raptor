class ChangePsarSignon2ToRegistrationId < ActiveRecord::Migration
  def self.up
    # First we delete all the PSARs where we do not have a registration -- this is not reversable
    execute "DELETE FROM cached_psars WHERE signon2 NOT IN
             ( SELECT psar_number FROM cached_registrations WHERE psar_number IS NOT NULL )"

    # Next we create the registration_id field
    add_column :cached_psars,         :registration_id, :integer
    add_column :cached_registrations, :last_day_fetch,  :datetime
    add_column :cached_registrations, :last_all_fetch,  :datetime

    # Now set the registration_id
    execute "UPDATE cached_psars SET
             registration_id = ( SELECT id
                                 FROM cached_registrations
                                 WHERE signon2 = psar_number )"

    # We now delete the old signon2 field.
    remove_column :cached_psars, :signon2

    # Set registration_id column as not null after it has been filled in.
    execute "ALTER TABLE cached_psars ALTER COLUMN registration_id SET NOT NULL"

    # We also add in a foreign key constraint
    execute "ALTER TABLE cached_psars ADD CONSTRAINT fk_cached_psars_registration_id
             FOREIGN KEY (registration_id) REFERENCES cached_registrations(id)
             ON DELETE CASCADE"
  end

  def self.down
    # Drop the foreign constraint
    execute "ALTER TABLE cached_psars DROP CONSTRAINT fk_cached_psars_registration_id"

    # We add back in the signon2 field
    add_column :cached_psars, :signon2, :string, :limit => 6
    
    # We set the signon2 back like it was
    execute "UPDATE cached_psars SET
             signon2 = ( SELECT psar_number
                         FROM cached_registrations reg
                         WHERE registration_id = reg.id )"

    # Now we removed the registration_id column
    remove_column :cached_psars,         :registration_id
    remove_column :cached_registrations, :last_day_fetch
    remove_column :cached_registrations, :last_all_fetch
  end
end
