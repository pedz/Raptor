# -*- coding: utf-8 -*-

# A cached version of the retain "registration" -- what you see when
# you do a DR command.
#
# +signon+:: +string+ -- Retain Signon
# +psar_number+:: +string+ -- Retain PSAR (appears to be the user's
#                            employee number)
# +name+:: +string+ -- Full name of the user
# +telephone+:: +string+ -- Telephone for the user
# +software_center+:: +string+ -- Users home software center (if any)
# +hardware_center+:: +string+ -- Users home hardware center
# +timestamps+:: +timestamp+ -- Usual time stamps
class CreateCachedRegistrations < ActiveRecord::Migration
  def self.up
    create_table :cached_registrations do |t|
      t.string  :signon,    :null => false
      t.integer :software_center_id
      t.integer :hardware_center_id
      t.string  :psar_number
      t.string  :name
      t.string  :telephone_number
      t.boolean :daylight_savings_time
      t.integer :time_zone_adjustment
      t.timestamps
    end
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT uq_cached_registrations_signon
             UNIQUE (signon)"
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT fk_cached_registrations_software_center_id
             FOREIGN KEY (software_center_id) REFERENCES cached_centers(id)
             ON DELETE CASCADE"
    execute "ALTER TABLE cached_registrations ADD CONSTRAINT fk_cached_registrations_hardware_center_id
             FOREIGN KEY (hardware_center_id) REFERENCES cached_centers(id)
             ON DELETE CASCADE"
  end

  def self.down
    drop_table :cached_registrations
  end
end
