# -*- coding: utf-8 -*-

module Cached
  # Queue Info is simply a many to many mapping of queues to the
  # registration records of the "owners".  This is over designed since
  # it appears that a queue can have either zero or one owner.
  class QueueInfo < Base
    set_table_name "cached_queue_infos"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :owner, :class_name => "Cached::Registration"
  end
end
