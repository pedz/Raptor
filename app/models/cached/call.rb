# -*- coding: utf-8 -*-

# == Cached Retain Models
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
  # === Retain Call Model
  #
  # This model is the database cached version of a Retain call.  The
  # database table is <em>cached_calls</em>.
  class Call < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: queue_id
    # The id from the cached_queues table that this call belongs to.
    # This is used to create the queue belongs to method.

    ##
    # :attr: ppg
    # The call's ppg.  A three letter Retain concept.  The first
    # letter is a digit and is equal to the call's priority.  The next
    # two letters is a weird hex kind of format.  The ppg will be
    # unique for a given queue and will not change for a call until it
    # is deleted or requeued.  Raptor uses a four tuple to uniquely
    # identify a call at a particular point in time.  The four tuple
    # is the queue's name, the queue's h_or_s value, the center's
    # name, and the ppg of the call.

    ##
    # :attr: pmr_id
    # The id from the cached_pmrs tabble that is the PMR that this
    # call belongs to.

    ##
    # :attr: priority
    # The call's priority.  Note that the PMR also has a priority and
    # a severity.  All the user interfaces appear to show the call's
    # priority and severity.

    ##
    # :attr: p_s_b
    # Set to 'P' for the primary call, 'S' for a secondary, and 'B'
    # for a backup.  Note that this is a weird Retain field because it
    # only shows up when doing a "CS" on a queue.  It does not appear
    # to be a field in the call.

    ##
    # :attr: comments
    # What might be considered the call's title or abstract.  This is
    # the field that consumes most of the space on a typical CS screen.

    ##
    # :attr: nls_customer_name
    # The NLS version of the customer's name.  Note that this can be
    # changed and can be different from what is in the Customer record.

    ##
    # :attr: nls_contact_name
    # The NLS version of the contact's name.

    ##
    # :attr: contact_phone_1
    # The first phone for the contact

    ##
    # :attr: contact_phone_2
    # The second phone for the contact

    ##
    # :attr: cstatus
    # The cstatus field (call status) field from Retain.

    ##
    # :attr: category
    # The categoy of the call

    ##
    # :attr: system_down
    # The system down flag

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: slot
    # When the calls are fetched with the Retain::Pmcs call, the order
    # that they come from Retain is recorded in this field.  It turns
    # out to be rather useless since it does not seem to match the
    # order of the green screen's presentations.

    ##
    # :attr: call_search_result
    # This attempts to be a unique string for a call until it has
    # changed in some way.  This is retrieved during a Retain::Pmcs
    # call and is saved in order to identify new calls on the queue.

    ##
    # :attr: dirty
    # Several database models have a dirty bit which is a Raptor
    # concept.  If Raptor knows that its database entry is out of
    # date, it will set this bit.  An example is immediately after an
    # update, the records being updated are marked as dirty.  This
    # will cause Raptor to fetch a new copy from Retain when the next
    # user requests the record.

    ##
    # :attr: customer_time_zone_adj
    # A Retain field associated with the call that is used to
    # determine the end customer's time zone.

    ##
    # :attr: time_zone_code
    # The end customer's time zone code.

    ##
    # :attr: last_fetched
    # A Raptor concept of the last time this record changed.  The
    # updated_at is used to determine when the query Retain and it is
    # updated when the query is made.  last_fetched changes only when
    # the data retrieved is different.  last_fetched is used to tag
    # the caches.  However, records sent to the browser use the
    # updated_at entry because the end user wants to know when Retain
    # was last queried.  This causes increase load on the network
    # traffic.

    ##
    # :attr: dispatched_employee
    # Which "DR" is dispatched (if any) to the call.

    ##
    # :attr: call_control_flag_1
    # A set of flags from Retain.  One bit is set if the call is
    # dispatched.

    ##
    # :attr: severity
    # The call's severity

    ##
    # :attr: owner_css
    # A Raptor concept used by Raptor I and is the css class name for
    # the owner field.  The owner, resolver, and next_queue css,
    # message, and editoable fields are Raptor concepts and are
    # computed when the call is updated and cached in an attempt to
    # save time on the combined_qs page.

    ##
    # :attr: owner_message
    # The title message that pops up for the Raptor I owner field.

    ##
    # :attr: owner_editable
    # True if the owner field is editable according to the Raptor I criteria.

    ##
    # :attr: resolver_css
    # The css class for the resolver button

    ##
    # :attr: resolver_message
    # The title message for the resolver button

    ##
    # :attr: resolver_editable
    # The editable flag for the resolver button.

    ##
    # :attr: next_queue_css
    # The css class for the next queue button.

    ##
    # :attr: next_queue_message
    # The title message for the next queue button.

    ##
    # :attr: next_queue_editable
    # The editable flag for the next queue button.

    set_table_name "cached_calls"

    ##
    # :attr: queue
    # A belongs_to association to the Cached::Queue the call is on.
    belongs_to :queue, :class_name => "Cached::Queue"

    ##
    # :attr: pmr
    # A belongs_to association to the Cached::Pmr of the call.
    belongs_to :pmr,   :class_name => "Cached::Pmr"

    ##
    # The call_search_result causes the json utf-8 encoder to blow up
    # -- probably because it is not valid utf-8?
    def as_json(options = { })
      if options.has_key?(:except)
        v = options[:except]
        if v.is_a? Array
          unless v.include?(:call_search_result)
            v.push(:call_search_result)
          end
        else
          v = [ v, :call_search_result ]
        end
      else
        v = [ :call_search_result ]
      end
      options = options.merge({ :except => v})
      super(options)
    end
    
    ##
    # During the processing of a queue via the Retain::Pmcs call, the
    # existing database calls are marked as unused and then set to
    # used as they are discovered in the new data.  The unused calls
    # are then deleted from the database.  This is the setter for that
    # Ruby attribute.
    def used=(value)
      @used = value
    end

    ##
    # Getter for the used attribute.
    def used
      @used
    end

    ##
    # The etag used for calls
    def etag
      [ call_search_result, last_fetched, pmr.etag ].flatten
    end
    once :etag
    
    ##
    # The tag used by the memcache which is designed to be the same
    # value until a field in the call changes.
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
