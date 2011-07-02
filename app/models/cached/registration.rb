# -*- coding: utf-8 -*-

module Cached
  class Registration < Base
    set_table_name "cached_registrations"
    belongs_to :software_center,  :class_name => "Cached::Center"
    belongs_to :hardware_center,  :class_name => "Cached::Center"
    has_many   :pmrs_as_owner,    :class_name => "Cached::Pmr",       :foreign_key => "owner_id"
    has_many   :pmrs_as_resolver, :class_name => "Cached::Pmr",       :foreign_key => "resolver_id"
    has_many   :queue_infos,      :class_name => "Cached::QueueInfo", :foreign_key => "owner_id"
    has_many   :queues,           :through    => :queue_infos
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
    
    # Registration Time Zone as a rational fraction of a day
    #
    # Note that the Combined model has the same method.
    def tz
      time_zone_adjustment.to_r / (24 * 60)
    end
    once :tz
  end
end
