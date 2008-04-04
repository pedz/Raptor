module Cached
  class Call < Base
    set_table_name "cached_calls"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :pmr,   :class_name => "Cached::Pmr"

    # The current definition of when initial response is needed is
    # every time the call is queued back to the center.  In theory,
    # this applies to world trade and not U.S.  For U.S., I don't have
    # a clear definition but in practical terms it is the same since
    # PMRs are never queued back out of the center.
    #
    # For secondary and backups, needs initial response is always
    # false.
    #
    # For the primary, we run through the signature lines looking for
    # CR's of the primary setting +ret+ to +true+.  The last of these
    # will be the requeue to the current location.  If we find a CT
    # signature line after this with the same center, we turn +ret+
    # back to +false+.  After all the signature lines are processed,
    # we return +ret+.  Note that +center+ in this case is the center
    # that the call (which is the primary call) is currently in.
    def needs_initial_response?
      return false if p_s_b != 'P'
      cmb = to_combined
      center = cmb.queue.center.center
      ret = false
      cmb.pmr.signature_lines do |sig|
        # Set ret to true for any requeue of the primary.  The last
        # one will be the requeue to the current location.
        if sig.stype == 'CR' && sig.ptype == '-'
          ret = true
        end
        # Set ret to false for any CT from this center.
        if sig.stype == 'CT'  && sig.center == center
          ret = false
        end
      end
      # Ret will be the last toggle from the above two conditions.
      ret
    end
    once :needs_initial_response?
    
    def center_entry_time(center = queue.center)
      if sig = center_entry_sig(center)
        sig.date
      else
        to_combined.pmr.create_time
      end
    end

    # Returns the signature for the CR that put the call into the
    # designated center
    def center_entry_sig(center = queue.center)
      if @entry_sig.nil?
        @entry_sig = { }
      end

      return @entry_sig[center] if @entry_sig[center]

      # We look at the call requeues for the primary call only (ptype
      # is blank).  If we hit a CR with the center, we return the
      # previous signature.  Otherwise, we return the last signature
      # for the primary.
      sig = to_combined.pmr.signature_line_stypes('CR').inject(nil) { |prev, s|
        if s.ptype == ' '
          if s.center == center
            return @entry_sig[center] = prev
          else
            s
          end
        else
          prev
        end
      }
      @entry_sig[center] = sig
    end

  end
end
