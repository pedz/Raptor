module Cached
  class Center < Base
    set_table_name "cached_centers"

    has_many :customers,              :class_name => "Cached::Customer"
    has_many :queues,                 :class_name => "Cached::Queue"
    has_many :software_registrations, :class_name => "Cached::Registration", :foreign_key => "software_center_id"
    has_many :hardware_registrations, :class_name => "Cached::Registration", :foreign_key => "hardware_center_id"
  end
end
