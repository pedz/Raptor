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
      t.string :signon, :null => false
      t.string :psar_number
      t.string :name
      t.string :telephone_number
      t.string :software_center
      t.string :hardware_center
      t.timestamps
    end
  end

  def self.down
    drop_table :cached_registrations
  end
end
