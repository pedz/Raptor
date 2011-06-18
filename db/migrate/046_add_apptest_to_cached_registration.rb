# -*- coding: utf-8 -*-
#
# Migration to add an apptest column to the Cached::Registrations
# model.
#
class AddApptestToCachedRegistration < ActiveRecord::Migration
  # 1 Add apptest boolean to Cached::Registrations.  The default is
  #   false and the column can not be null.
  # 2 Drop the old uq_cached_registrations_signon constraint
  # 3 Add a new uq_cached_registrations_signon which is UNIQUE
  #   (signon, apptest)
  def self.up
    # Add the new apptest column
    add_column :cached_registrations, :apptest, :boolean, :default => false, :null => false

    # Drop the old, more restricted constraint
    execute "ALTER TABLE cached_registrations DROP CONSTRAINT uq_cached_registrations_signon"

    # Add in the constraint that within the APPTEST or production
    # systems, only one record with the same signon is allowed
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT uq_cached_registrations_signon
             UNIQUE (signon, apptest)"
  end

  # 1 Delete all Cached::Registrations where apptest is true
  # 2 Drop the new uq_cached_registrations_signon
  # 3 Restore the original uq_cached_registrations_signon which is
  #   UNIQUE (signon)
  # 4 Drop the apptest column from Cached::Registrations
  def self.down
    # To get back where we were, we have to delete all the apptest registrations.
    execute "DELETE FROM cached_registrations WHERE apptest = true"
    
    # Now we drop the "new" constraint
    execute "ALTER TABLE cached_registrations DROP CONSTRAINT uq_cached_registrations_signon"

    # Add back in the original constraint of only one registration is
    # allowed per signon
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT uq_cached_registrations_signon
             UNIQUE (signon)"

    # Now drop the apptest column
    remove_column :cached_registrations, :apptest
  end
end
