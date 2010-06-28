# -*- coding: utf-8 -*-

# = Cached Favorite Queue
#
# The "cached" part may be erroneous since this is not a copy of what
# is in Retain -- although it could be pulled from the list in Retain.
# In any case, this is a list of queues that a user decides are their
# favorites.  It belongs to a user and not a retuser which may be a
# mistake as well.
#
# ==Fields
# <em>id - integer</em>:: Key for the table
# <em>user_id - integer</em>:: Foreign key to users table
# <em>queue_id - integer</em>:: Foreign key to cached_queues table
# 
module Cached
  class FavoriteQueue < Base
    set_table_name "favorite_queues"
    belongs_to :retuser
    belongs_to :queue, :class_name => "Cached::Queue" # , :extend => WrapWithCombine
  end
end
