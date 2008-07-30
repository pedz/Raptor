module Cached
  class Psar < Base
    set_table_name "cached_psars"
    belongs_to :pmr,          :class_name => "Cached::Pmr"
    belongs_to :center,       :class_name => "Cached::Center"
    belongs_to :queue,        :class_name => "Cached::Queue"
    belongs_to :registration, :class_name => "Cached::Registration"
    # There is also a belongs_to for APARs but it is not used in our
    # area so it is not hooked up yet.
    named_scope :today, lambda { { :conditions => { :psar_system_date => Time.now.strftime('%y%m%d') } } }
  end
end
