module Retain
  module FavoriteQueuesHelper
    # Passed a combined queue.  We do a PMCS to get just the hits --
    # hoping it will be cheaper.  Plus, we do not cache it up.
    def queue_hits(queue)
      options = {
        :queue_name => queue.queue_name,
        :center => queue.center,
        :h_or_s => queue.h_or_s
      }
      cq = Retain::Cq.new(options)
      cq.hit_count
    end
  end
end
