# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
# A database view to simplify the code.  This is a join between the
# users table and the entities view along with a left outer join to
# the use_counters table such that each user has an entry for each
# entity even if the user has never picked.
class UserEntityCount < ActiveRecord::Base
  # :attr: user_id
  # The id field from the users table

  # :attr: name
  # The name field from the entities view

  # :attr: argument_type
  # The argument_type field from the entities view

  # :attr: real_type
  # The real_type field from the entities view

  # :attr: count
  # Either 0 if there is no matching entry in the use_counters table
  # or the value from use_counters table if there is a matching
  # entry.

  # :attr: updated_at
  # Either the updated_at field from the users table or the updated_at
  # field from the use_counters table if a matching entry was found.
end
