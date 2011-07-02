# -*- coding: utf-8 -*-

module Cached
  #
  # In Retain, a queue is not a real object or entity so there are
  # very few fields in the database for a queue.  The database table
  # is cached_queues.
  class Queue < Base
    class << self
      def base_class
        self
      end
    end

    ##
    # :attr: id
    # The Integer key to the table.

    ##
    # :attr: queue_name
    # A String name of the queue, e.g PTTY

    # :attr: h_or_s
    # A one byte String for the hardware or software flag.  This
    # corresponds to SDI field 1135 and can be either 'S' or 'H' (in
    # EBCDIC).  This designates the queue as either a "software" queue
    # or a "hardware" queue.  It appears as if a center is actually
    # hardware or software specific but the Retain SDI calls are set
    # up to make it appear to be an attribute of the queue.

    # :attr: center_id
    # The Integer id for a Center in which the queue lives.

    # :attr: created_at - timestamp without time zone
    # Usual timestamp when db record was created.

    # :attr: updated_at
    # Usual Timestamp without time zone when db record was last
    # updated.  As with Cached::Queues and Cached::Pmrs, this field is
    # used to determine when Retain is queried to verify if the data
    # cached in the database is up to date.  See last_fetched as well.

    # :attr: dirty
    # A Boolean field set to true when it is known that the database
    # entry is not up to date, this bit is set to true.

    # :attr: last_fetched
    # This is the Timestamp without time zone when the data from
    # Retain caused the database record to be updated because it had
    # changed.  To put in other words, updated_at is used to determine
    # when to query Retain.  If the date fetched from Retain is
    # different from the data cached in the database, then the
    # database is updated and last_fetched is set to the current time
    # of day.  As with Cached::Call#last_fetch, this field is updated
    # if the last_fetched field for any of calls is updated.  It
    # *should* always be the case that the last_fetched field of the
    # queue is the most recent of all the calls which are more recent
    # than their associated problem records.

    set_table_name "cached_queues"

    ##
    # :attr: center
    # A belongs_to association to a Center
    belongs_to :center,          :class_name => "Cached::Center"

    ##
    # :attr: calls
    # A has_many association to Cached::Call.
    has_many(:calls,
             :class_name => "Cached::Call",
             :dependent => :delete_all,
             :order => "slot",
             :include => :pmr)

    ##
    # :attr: favorite_queues
    # A has_many association to FavoriteQueue.
    has_many :favorite_queues

    ##
    # :attr: next_queue_pmrs
    # A has_many association to Cached::Pmr and contains all the calls
    # using this queue as the next queue.  (I don't think this is used
    # anywhere.)
    has_many :next_queue_pmrs, :class_name => "Cached::Pmr", :foreign_key => "next_queue_id"

    ##
    # :attr: queue_info
    # A has_many to Cached::QueueInfo which creates a has and belongs
    # to many join table joining Cached::Queue to a
    # Cached::Registration owner.  (I made this overly flexible.)
    has_many :queue_infos, :class_name => "Cached::QueueInfo", :foreign_key => "queue_id"

    ##
    # :attr: owners
    # A has_many association to Cached::Registration for the owners of
    # this queue.
    has_many :owners, :through    => :queue_infos

    ##
    # :attr: psars
    # A has_many association to Cached::Psar with this queue as the
    # charge-able queue.
    has_many :psars, :class_name => "Cached::Psar"

    ##
    # :attr: item_relationships
    # A has_many assocation to Relationship that uses this object as
    # the item being contained.
    has_many :item_relationships, :class_name => "Relationship", :as => :item

    ##
    # :attr: item_containments
    # A has_many assocation to Containment that uses this object as
    # the item being contained.
    has_many :item_containments, :class_name => "Containment", :as => :item

    ##
    # :attr: nestings
    # A has_many association to Nesting that specifies this Name as the
    # container.
    has_many :nestings, :as => :container

    ##
    # :attr: item_nestings
    # A has_many assocation to Nesting that uses this object as
    # the item being contained.
    has_many :nesting_items, :class_name => "Nesting", :as => :item

    # A class method that returns the list of team queues.  This are
    # queues that do not have a Cached::QueueInfo entry.
    def self.team_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        q.team_queue?
      }
    end

    # A class method that returns the list of personal queues which
    # are queues that have a Cached::QueueInfo
    def self.personal_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        not q.team_queue?
      }
    end

    # method to compute a hash tag
    def etag
      a = calls.map { |call| call.etag }
      a << last_fetched
      a.flatten
    end
    once :etag

    # Returns true if this is considered a team queue.  The test is to
    # see if owners is empty.
    def team_queue?
      self.owners.empty?
    end

    # Put this down into the cached version so we are only dealing
    # with database entries
    def mark_pmrs_as_dirty
      calls.each { |call| call.pmr.mark_as_dirty }
    end

    # Common method needed by any class that will be an item in a
    # container.
    def item_name
      "#{queue_name},#{h_or_s},#{center.center}"
    end
  end
end
