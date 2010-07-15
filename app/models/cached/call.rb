# -*- coding: utf-8 -*-

# = Cached Retain Models
#
# The various retain concepts such as Pmr, Call, Queue, etc are
# fetched from Retain using SDI and cached in a local database.  Each
# database table is prefixed with <em>cached</em>:
# e.g. <em>cached_pmrs</em>.
#
# Note that some Retain models are not cached.  This usually because
# the Retain model was created as part of testing or experimentation.
# Some Retain models will likely be cached eventually.
#
module Cached
  # =Retain Call Model
  #
  # This model is the database cached version of a Retain call.  The
  # database table is <em>cached_calls</em>.
  #
  # ==Fields
  #
  # <em>id - integer</em>::
  #   Key for the table.
  # <em>queue_id - integer</em>::
  #   Foreign key to <em>cached_queues</em>
  # <em>ppg - character varying(3)</em>::
  #   The queue_id and the ppg uniquely specify a call.  The two items
  #   create a 4-tuple of queue,h_or_s,center,ppg.  For example
  #   pedz,S,165,221.
  # <em>pmr_id - integer</em>::
  #   A call always points to a single PMR (Problem Record).  A Call is
  #   what is actually on a queue but they are oftem called PMRs by
  #   mistake.  pmd_id is a foreign key to the cached_pmrs table.
  # <em>priority - integer</em>::
  #   Each call has a priority.  The PMR has a severity.
  # <em>p_s_b - character varying(1)</em>::
  #   A call can be a primary, secondary, or backup.  The p_s_b field
  #   is in some Retain SDI calls but not others.
  # <em>comments - character varying(54)</em>::
  #   The comments field is what most people would call the PMR's
  #   title.  Note it is a call field so each call has different
  #   comments.
  # <em>nls_customer_name - character varying(28)</em>::
  #   The customer, company, and contact are also actually call
  #   specific fields even though that does not make a lot of sense.
  #   A field with nls in the front denotes a field that carries a
  #   CCSID which is the Retain way of denoting the code page.
  # <em>nls_contact_name - character varying(30)</em>::
  #   The contact as listed in the calls header
  # <em>contact_phone_1 - character varying(19)</em>::
  #   The contact's first phone number
  # <em>contact_phone_2 - character varying(19)</em>::
  #   The contacts second phone number
  # <em>cstatus - character varying(7)</em>::
  #   The cstatus field from Retain (SDI field 1633).
  # <em>category - character varying(3)</em>::
  #   Text
  # <em>system_down - boolean</em>::
  #   The system down boolean flag
  # <em>created_at - timestamp without time zone</em>::
  #   Typical timestamp to record when the database record was created.
  # <em>updated_at - timestamp without time zone</em>::
  #   Timestamp to record the last time the database record was
  #   updated.  This timestamp is used to determine when Retain should
  #   be queried again under normal conditions to verify that the
  #   current local copy is up to date.  See also the last_fetched
  #   timestamp.
  # <em>slot - integer</em>::
  #   When the PMCS SDI call is done to get the list of calls on a
  #   queue, they are presented in a particular order.  slot is the 0
  #   based index of the order.  It is *not* the same order as the
  #   calls are presented in the "Raw Retain" list.
  # <em>call_search_result - bytea</em>::
  #   Each call has a unique blob attached to it.  This blob actually
  #   encodes the center, queue_name, and ppg (but not the h or s
  #   field).  The call_search_result is used to make sure that two
  #   calls are the same (i.e. when comparing a fresh list of calls
  #   retrieved from retain and a list in the database, the
  #   call_search_result is what is used to make the comparison.
  # <em>dirty - boolean</em>::
  #   If we know that the database record is out of date, we set the
  #   dirty bit.
  # <em>customer_time_zone_adj - integer</em>::
  #   The time zone adjustment for the customer of the call.  There may
  #   be remnants still around so I will explain that I did not know
  #   this field existed so I had a long involved process of going
  #   from the call to the customer record or the center to get the
  #   timezone for the customer.  I know should use this field but I
  #   may still use the other fields in the code somewhere.
  # <em>time_zone_code - integer</em>::
  #   Timezones in Retain are a bit weird.  There is a binary form and
  #   a text form.  I usually fetch both since each is easier to use
  #   in different places.
  # <em>last_fetched - timestamp without time zone</em>::
  #   This is the time stamp of when the call was fetched from Retain
  #   *and* it was different than what was in the database.  It is the
  #   time stamp used to determine if a page, action, or fragment
  #   cache entry is up to date.  If the pmr's last_fetched field is
  #   changed, this field will also be changed because the fragment
  #   must be rendered again.
  class Call < Base
    set_table_name "cached_calls"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :pmr,   :class_name => "Cached::Pmr"

    # The call_search_result causes the json utf-8 encoder to blow up
    # -- probably because it is not valid utf-8?
    # set_as_json_default_options(:except => [ :call_search_result ])
    def as_json(options = { })
      super({ :except => [ :call_search_result ] })
    end

    # The current definition of when initial response is needed is
    # every time the call is queued back to the center.  In theory,
    # this applies to world trade and not U.S.  For U.S., I don't have
    # a clear definition but in practical terms it is the same since
    # PMRs are never queued out of the center.
    #
    # For secondary and backups, needs initial response is always
    # false.
    #
    # For the primary, we run through the signature lines looking for
    # CR's of the primary setting with the center for the center *not*
    # equal to the center the call is on and we set +ret+ to +true+.
    # The last of these will be the requeue to the current location.
    # If we find a CT signature line after this with the same center,
    # we turn +ret+ back to +false+.  After all the signature lines
    # are processed, we return +ret+.  Note that +center+ in this case
    # is the center that the call (which is the primary call) is
    # currently in.
    def needs_initial_response?
      # logger.debug("CHC: needs_initial_response '#{p_s_b}'")
      return false if p_s_b != 'P'
      # logger.debug("CHC: needs_initial_response still here")
      cmb = to_combined
      center = cmb.queue.center.center
      ret = false
      cmb.pmr.signature_lines.each do |sig|
        # logger.debug("CHC: stype=#{sig.stype} ptype=#{sig.ptype}")
        # Set ret to true for any requeue of the primary.  The last
        # one will be the requeue to the current location.
        if sig.stype == 'CR' && sig.ptype == '-' && sig.center != center
          # logger.debug("CHC: CR line at #{sig.date}")
          ret = true
        end
        # Set ret to false for any CT from this center.
        if sig.stype == 'CT'  && sig.center == center
          # logger.debug("CHC: CT line at #{sig.date}")
          ret = false
        end
      end
      # Ret will be the last toggle from the above two conditions.
      ret
    end
    once :needs_initial_response?
    
    def used=(value)
      @used = value
    end

    def used
      @used
    end

    def center_entry_time(center = queue.center)
      if sig = center_entry_sig(center)
        sig.date
      else
        to_combined.pmr.create_time
      end
    end
    once :center_entry_time

    def etag
      [ call_search_result, last_fetched, pmr.etag ].flatten
    end
    once :etag

    # Returns the signature for the CR that put the call into the
    # designated center
    def center_entry_sig(center = queue.center)
      # We return the last signature for a call requeue for the
      # primary (ptype == '-') that is not from within the center.
      sig = to_combined.pmr.signature_line_stypes('CR').inject(nil) { |prev, s|
        if (s.ptype == '-') && (s.center != center.center)
          s
        else
          prev
        end
      }
      sig
    end
    once :center_entry_sig
    
    def cache_tag(tag)
      # We are down in the cached model so the "auto-fetch magic" does
      # not work.  We have to check for nil in all the various fields
      t = Time.now
      t = last_fetched unless last_fetched.nil?
      t = pmr.last_fetched unless pmr.nil? || pmr.last_fetched.nil? || pmr.last_fetched < t
      q = queue
      c = queue.center
      "#{q.queue_name},#{q.h_or_s},#{c.center},#{ppg}-#{t.tv_sec}.#{t.usec}-#{tag}"
    end
  end
end
