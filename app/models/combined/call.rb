module Combined
  class Call < Base
    add_skipped_fields :queue_id, :pmr_id
    add_extra_fields :problem, :branch, :country

    def cache_valid
      self.cached.updated_at
    end

    #
    # The to_s is called for named routes
    #
    def to_s
      queue.to_s + ',' + ppg
    end
  end
end
