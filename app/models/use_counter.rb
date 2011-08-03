# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# When a user picks an entity in a browser page, a use count is
# incremented.  This is the model for that usage count.  The use
# counts then change how the table of choices are presented to the
# user so that their most frequent choices are at the top of the
# list.
class UseCounter < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: user_id
  # The id field from the users table.

  ##
  # :attr: name
  # The name of the entity

  ##
  # :attr: count
  # The count of times the specified user has picked the specified
  # entity.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

end
