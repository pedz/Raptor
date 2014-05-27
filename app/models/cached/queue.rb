# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Cached
  # === Retain Quue model
  #
  # In Retain, a queue is not a real object or entity so there are
  # very few fields in the database for a queue.  The database table
  # is cached_queues.
  class Queue < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.
    ##
    # :attr: queue_name
    # The name of the queue .e.g. PEDZ or PTTY

    ##
    # :attr: h_or_s
    # Set to 'H' if this is a hardware queue or 'S' if this is a
    # software queue.

    ##
    # :attr: center_id
    # The id from the cached_centers table for the center that this
    # queue belongs to.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: dirty
    # See Cached::Call#dirty

    ##
    # :attr: last_fetched
    # See Cached::Call#last_fetched

    class << self
      ##
      # Overrides the ActiveRecord method which returns just "Queue".
      # This, instead, returns "Cached::Queue".  This is needed to get
      # things to work right for entities and relationships.
      def base_class
        self
      end
    end

    ##
    # :attr: expire_time
    # Set to 5.minutes
    set_expire_time 5.minutes

    set_table_name "cached_queues"

    ##
    # :attr: center
    # A belongs_to association to the Cached::Center this queue
    # belongs to.
    belongs_to :center,          :class_name => "Cached::Center"

    ##
    # :attr: calls
    # A has_many association to the Cached::Call entries currently on
    # the queue.
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
    # Cached::Registration owner.  This allows a person to have more
    # than one personal queue or a queue to be the personal queue for
    # more than one person.  This flexibility is currently not used.
    has_many :queue_infos, :class_name => "Cached::QueueInfo", :foreign_key => "queue_id"

    ##
    # :attr: owners
    # A has_many association to Cached::Registration for the owners of
    # this queue.  Note that there are parts of Raptor that assume
    # that if this is empty then the queue is an incoming team queue.
    # This logic predates the Teams concept that Raptor now has.
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
    # A has_many association to Nesting that uses this object as
    # the item being contained.
    has_many :nesting_items, :class_name => "Nesting", :as => :item

    ##
    # :attr: rotation_group
    # A has_many association to RotationGroup
    has_many :rotation_groups

    ##
    # A class method that returns the list of team queues.  These are
    # queues that do not have a Cached::QueueInfo entry.
    def self.team_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        q.team_queue?
      }
    end

    ##
    # A class method that returns the list of personal queues which
    # are queues that have a Cached::QueueInfo
    def self.personal_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        not q.team_queue?
      }
    end

    ##
    # method to compute a hash tag for the queue.  The etag and the
    # last modified attributes are sent to the browser.  The browser
    # then sends them back on the next request to the same URL.  Rails
    # can then compare these and return a 304 reply telling the
    # browser that its entry is still valid and reduce the network
    # load.
    def etag
      a = calls.map { |call| call.etag }
      a << last_fetched
      a.flatten
    end
    once :etag

    ##
    # Returns true if this is considered a team queue.  The test is to
    # see if owners is empty.
    def team_queue?
      self.owners.empty?
    end

    ##
    # Marks all the PMRs associated with the current calls on the
    # queue as dirty.  This is done when the user issues a combined_qs
    # request with the no cache flag set (i.e. he does a shift+refresh
    # while on the combined_qs page).
    def mark_pmrs_as_dirty
      calls.each { |call| call.pmr.mark_as_dirty }
    end

    ##
    # Common method needed by any class that will be an item in a
    # container.
    def item_name
      "#{queue_name},#{h_or_s},#{center.center}"
    end

    def self.find_by_item_name(name)
      queue_name, h_or_s, center = name.split(',')
      c = Cached::Center.find_or_create_by_center(center)
      c.queues.find_or_create_by_queue_name_and_h_or_s(queue_name, h_or_s)
    end
  end
end
