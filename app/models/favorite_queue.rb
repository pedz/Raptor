# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# === Favorite Queue
#
# A favorite queue is a queue that a user sets up.  It belongs to a
# retuser.
#
class FavoriteQueue < ActiveRecord::Base
  ##
  # :attr: id
  # The key to the table.

  ##
  # :attr: queue_id
  # The id from the cached_queues table
  
  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: retuser_id
  # The id from the retusers table.

  ##
  # :attr: sort_column
  # An integer position of where the user wants to view this queue in
  # their list.

  set_table_name "favorite_queues"

  ##
  # :attr: retuser
  # A belongs_to association to a Retuser that owns the entry.
  belongs_to :retuser

  ##
  # :attr: queue
  # A belogns_to association to a Cached::Queue that the entry refers
  # to.
  belongs_to :queue, :class_name => "Cached::Queue"
end
