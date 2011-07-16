# -*- coding: utf-8 -*-

module Cached
  # === Retain Center Model
  #
  # This model is the database cached version of a Retain center.  The
  # database table is <em>cached_centers</em>.  The fields cached from
  # Retain are a bit arbitrary and might need to be reviewed at some
  # point.
  class Center < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: center
    # A Retain field which is the name of the center such as 165.

    ##
    # :attr: software_center_mnemonic
    # A Retain concept which is a mnemonic name for the center.

    ##
    # :attr: center_daylight_time_flag
    # A Retain concept which is a flag if the center observes daylight
    # savings time.

    ##
    # :attr: delay_to_time
    # A Retain concept which I am not sure what it is.

    ##
    # :attr: minutes_from_gmt
    # A Retain concept that is the timezone offset for the center.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: absorbed_queue_list
    # The absorbed queue list for this center... like I know what that
    # is or something.

    set_table_name "cached_centers"

    ##
    # :attr: customers
    # A has_many assocation with the Cached::Customer entries that
    # belong to this center.
    has_many :customers,        :class_name => "Cached::Customer"

    ##
    # :attr: queues
    # A has_many association of Cached::Queue that belong to this
    # center.

    has_many :queues,           :class_name => "Cached::Queue"

    ##
    # :attr: next_center_pmrs
    # A has_many association to the Cached::Pmr entries that have this
    # center listed in its next center field.
    has_many :next_center_pmrs, :class_name => "Cached::Pmr", :foreign_key => "next_center_id"

    ##
    # :attr: psars
    # A has_many association to the Cached::Psar that has this center
    # listed
    has_many :psars,            :class_name => "Cached::Psar"

    ##
    # :attr: software_registrations
    # A has_many association to the Cached::Registration entries that
    # list this center as its software center.
    has_many(:software_registrations,
             :class_name => "Cached::Registration",
             :foreign_key => "software_center_id",
             :order => "name")

    ##
    # :attr: hardware_registrations
    # A has_many association to the Cached::Registration entries that
    # list this center as its hardware center.
    has_many(:hardware_registrations,
             :class_name => "Cached::Registration",
             :foreign_key => "hardware_center_id",
             :order => "name")
    
    ##
    # The concatination of software_registrations and
    # hardware_registrations
    def registrations
      software_registrations + hardware_registrations
    end
  end
end
