module Cached
  class Registration < Base
    set_table_name "cached_registrations"
    has_many :pmrs_as_owner,    :class_name => "Cached::Pmr",       :foreign_key => "owner_id"
    has_many :pmrs_as_resolver, :class_name => "Cached::Pmr",       :foreign_key => "resolver_id"
    has_many :queue_infos,      :class_name => "Cached::QueueInfo", :foreign_key => "owner_id"
    has_many :queues,           :through    => :queue_infos
    
    def default_center
      cmb = to_combined
      if cmb.software_center != "000"
        cmb.software_center
      elsif cmb.hardware_center != "000"
        cmb.hardware_center
      else
        nil
      end
    end
    once :default_center

    def default_h_or_s
      cmb = to_combined
      if cmb.software_center != "000"
        'S'
      elsif cmb.hardware_center != "000"
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
    def center(h_or_s)
      cmb = to_combined
      case
        # Simple cases
      when h_or_s == 'S' && cmb.software_center != "000"
        center = cmb.software_center
      when h_or_s == 'H' && cmb.hardware_center != "000"
        center = cmb.hardware_center
      else # Odd cases... sorta just guess.
        default_center
      end
    end
    once :center
    
    # Registration Time Zone as a rational fraction of a day
    def tz
      to_combined.time_zone_adjustment.to_r / (24 * 60)
    end
    once :tz

  end
end
