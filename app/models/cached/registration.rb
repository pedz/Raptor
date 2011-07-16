# -*- coding: utf-8 -*-

module Cached
  # === Retain Registration Model
  #
  # Sometimes referred to as the "DR" it mostly represents a user or a
  # support specialist from Retain's perspective.  There may be more
  # fields available that should be cached up.
  class Registration < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: signon
    # The user's "retain id".

    ##
    # :attr: software_center_id
    # The id from cached_centers for the software center the record is
    # associated with.

    ##
    # :attr: hardware_center_id
    # The id from cached_centers for the hardware center the record is
    # associated with.

    ##
    # :attr: psar_number
    # Retain uses a second number (this number) for the PSAR entries.

    ##
    # :attr: name
    # The name of the user (or specialist as the Retain documents
    # refer to them).

    ##
    # :attr: telephone_number
    # The telephone number of the user.  Note that its not clear how
    # up to date these entries are kept.

    ##
    # :attr: daylight_savings_time
    # A flag to indicate if the user observes daylight savings time.

    ##
    # :attr: time_zone_adjustment
    # A flag that is the time zone adjustment for this user.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: last_day_fetch
    # A Raptor only field that is the time when all the PSARs for the
    # day have been fetched.  This is usually done about once an hour
    # if the user is active.

    ##
    # :attr: last_all_fetch
    # A Raptor only field that is the time when all the PSARs that are
    # available for this user have been fetched.  This is usually done
    # once a day.

    ##
    # :attr: apptest
    # A flag that is true if this DR entry is for the APPTEST side of
    # Retain.  I'm not super happy with this decision.  A Raptor user
    # can have multiple Retuser and each Retuser can be either for the
    # real Retain or the APPTEST retain.  To make things consistent,
    # that flag is also propagated into these records.

    set_table_name "cached_registrations"

    ##
    # :attr: software_center
    # A belongs_to association to the Cached::Center for this DRs
    # software center.
    belongs_to :software_center,  :class_name => "Cached::Center"

    ##
    # :attr: hardware_center
    # A belongs_to association to the Cached::Center for this DRs
    # hardware center.
    belongs_to :hardware_center,  :class_name => "Cached::Center"

    ##
    # :attr: pmrs_as_owner
    # A has_many assocation to the Cached::Pmr entries that list this
    # DR as its owner.
    has_many   :pmrs_as_owner,    :class_name => "Cached::Pmr", :foreign_key => "owner_id"

    ##
    # :attr: pmrs_as_resolver
    # A has_many association to the Cached::Pmr entries that list this
    # DR as its resolver.
    has_many   :pmrs_as_resolver, :class_name => "Cached::Pmr", :foreign_key => "resolver_id"

    ##
    # :attr: queue_infos
    # A has_many association to the Cached::QueueInfo entries for this
    # DR.
    has_many   :queue_infos,      :class_name => "Cached::QueueInfo", :foreign_key => "owner_id"

    ##
    # :attr: queues
    # A has_many assocation to the Cached::Queue entries that are the
    # personal queues for this DR.
    has_many   :queues,           :through    => :queue_infos

    ##
    # :attr: psars
    # A has_many assocation to the Cached::Psar entries for this DR.
    has_many   :psars,            :class_name => "Cached::Psar"
    
    ##
    # Find the peronal queue via the QueueInfo relationships
    def personal_queue
      unless (local_queues = self.queues).empty?
        local_queues[0]
      end
    end
    once :personal_queue

    ##
    # Returns what we call the default center.  This is the software
    # center if the registration has one defined.  Else it is the
    # hardware center if the registration has one defined.  Else it is
    # nil.
    #
    # Note that the Combined model has the same method.
    def default_center
      if software_center
        software_center
      elsif hardware_center
        hardware_center
      else
        nil
      end
    end
    once :default_center

    ##
    # The default h or s is 'S' if the registration has a software
    # center defined, 'H' if it has a hardware center defined, or 'S'
    # otherwise.
    #
    # Note that the Combined model has the same method.
    def default_h_or_s
      if software_center
        'S'
      elsif hardware_center
        'H'
      else
        'S'
      end
    end
    once :default_h_or_s
    
    ##
    # If h_or_s is 'S' returns the software center if it is not null.
    # Else If h_or_s is 'H' returns the hardware center if it is not null.
    # Else return software center if it is not null,
    # Else return hardware center if it is not null,
    # Else return null.
    #
    # Note that the Combined model has the same method.
    def center(h_or_s)
      case
        # Simple cases
      when h_or_s == 'S' && software_center
        software_center
      when h_or_s == 'H' && hardware_center
        hardware_center
      else # Odd cases... sorta just guess.
        default_center
      end
    end
    once :center
    
    ##
    # Registration Time Zone as a rational fraction of a day
    #
    # Note that the Combined model has the same method.
    def tz
      time_zone_adjustment.to_r / (24 * 60)
    end
    once :tz
  end
end
