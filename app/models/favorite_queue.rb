# -*- coding: utf-8 -*-

# = Favorite Queue
#
# A favorite queue is a queue that a user sets up.  It belongs to a
# retuser.
#
# ==Fields
# <em>id - integer</em>:: Key for the table
# <em>retuser_id - integer</em>:: Foreign key to retusers table
# <em>queue_id - integer</em>:: Foreign key to cached_queues table
# 
class FavoriteQueue < ActiveRecord::Base
  set_table_name "favorite_queues"
  belongs_to :retuser
  belongs_to :queue, :class_name => "Cached::Queue" # , :extend => WrapWithCombine
end
