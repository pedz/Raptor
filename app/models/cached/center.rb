module Cached
  class Center < Base
    set_table_name "cached_centers"

    has_many :customers,        :class_name => "Cached::Customer"
    has_many :queues,           :class_name => "Cached::Queue"
    has_many :next_center_pmrs, :class_name => "Cached::Pmr", :foreign_key => "next_center_id"
    has_many(:software_registrations,
             :class_name => "Cached::Registration",
             :foreign_key => "software_center_id",
             :order => "name")
    has_many(:hardware_registrations,
             :class_name => "Cached::Registration",
             :foreign_key => "hardware_center_id",
             :order => "name")
    
    def registrations
      software_registrations + hardware_registrations
    end

    # Returns true if time is within the center's prime time shift.
    # Currently, daylight savings time is not considered.  The prime
    # shift is 8 a.m. to 5 p.m. (0800-1700) Monday through Friday.
    # time is assumed to be a DateTime object (or something that acts
    # like it).
    def prime_shift(time)
      logger.debug("CHC: prime_shift tz=#{tz}, time=#{time}")
      t = time.new_offset(tz)
      logger.debug("CHC: prime_shift new t = #{t}")
       (8 .. 17) === t.hour && (1 .. 5) === t.wday
    end

    # Center Time Zone as a rational fraction of a day
    def tz
      to_combined.minutes_from_gmt.to_r / (24 * 60)
    end
    once :tz
    
  end
end
