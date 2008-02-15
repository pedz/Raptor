module Cached
  class QueueInfo < Base
    set_table_name "cached_queue_infos"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :owner, :class_name => "Cached::Registration"
  end
end
