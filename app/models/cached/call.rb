module Cached
  class Call < Base
    set_table_name "cached_calls"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :pmr,   :class_name => "Cached::Pmr"

    def needs_initial_response?
      if @needs_initial_response.nil?
        center = self.queue.center
        @needs_initial_response = self.pmr.signature_line_stypes('CT').all? { |sig|
          sig.center != center
        }
      end
      @needs_initial_response
    end

    def center_entry_time(center = queue.center)
      if sig = center_entry_sig(center)
        sig.date
      else
        self.pmr.create_time
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
      sig = pmr.signature_line_stypes('CR').inject(nil) { |prev, s|
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
