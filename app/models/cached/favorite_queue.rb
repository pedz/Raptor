# -*- coding: utf-8 -*-

module Cached
  class FavoriteQueue < Base
    set_table_name "favorite_queues"
    belongs_to :user
    belongs_to :queue, :class_name => "Cached::Queue" # , :extend => WrapWithCombine
  end
end
