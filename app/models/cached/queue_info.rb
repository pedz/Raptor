# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Cached
  # === Retain Queue Owner join model

  # Queue Info is simply a many to many mapping of Cached::Queue to
  # Cached::Registration records of the "owners".  This is over
  # designed since it appears that a queue can have either zero or one
  # owner.
  class QueueInfo < Cached::Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: queue_id
    # The id from the cached_queues table for the queue this entry
    # refers to.

    ##
    # :attr: owner_id
    # The id from the cached_registrations table for the registraion
    # that this entry refers to.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    ##
    # :attr: expire_time
    # Set to :never
    set_expire_time :never

    set_table_name "cached_queue_infos"

    ##
    # A belongs_to association to a Cached::Queue
    belongs_to :queue, :class_name => "Cached::Queue"

    ##
    # A belongs_to association to the Cached::Registration
    belongs_to :owner, :class_name => "Cached::Registration"
  end
end
