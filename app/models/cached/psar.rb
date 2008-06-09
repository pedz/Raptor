module Cached
  class Psar < Base
    set_table_name "cached_psars"
    belongs_to :pmr,    :class_name => "Cached::Pmr"
    belongs_to :center, :class_name => "Cached::Center"
    belongs_to :queue,  :class_name => "Cached::Queue"
    # There is also belongs to for registrations and also for apars
    # but that hasn't been done yet.
  end
end
