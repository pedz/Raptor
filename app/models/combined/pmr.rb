module Combined
  class Pmr < Base
    add_skipped_fields :problem, :branch, :country

    def cache_valid
      cached.updated_at
    end

    def cache_valid
      self.cached.updated_at
    end

    def load
      logger.debug("CMD: load for <#{self.class.to_s}:#{"0x%x" % self.object_id}>")
      cached = self.cached

      # Fields used for the lookup
      lookup_fields = %w{ problem branch country }
      # Pull the fields we need
      options_hash = Hash[ * lookup_fields.map { |field|
                             [ field.to_sym, cached.attributes[field] ] }.flatten ]
      # We also need the signon and password but we get that from the Logon singleton
      
      # PMPB uses group_request.  Lets create that:
      group_request_elements = Combined::Pmr.retain_fields.map { |field| field.to_sym }
      options_hash[:group_request] = group_request_elements
      
      pmr = Retain::Pmr.new(options_hash)
      pmr.severity
      cached.update_attributes(Cached::Pmr.options_from_retain(pmr))
    end

    # A convenience method to give back the usual form of
    # problem,branch,country for a call.
    def pbc
      (problem + "," + branch + "," + country).upcase
    end
  end
end
