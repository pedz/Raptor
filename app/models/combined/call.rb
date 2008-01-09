module Combined
  class Call < Base
    add_skipped_fields "queue_id"

    def cache_valid
      self.cached.updated_at
    end

    # A convenience method to give back the usual form of
    # problem,branch,country for a call.
    def pbc
      "%s,%s,%s" % [ problem, branch, country ]
    end
  end
end
