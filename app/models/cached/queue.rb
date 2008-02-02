module Cached
  class Queue < Base
    set_table_name "cached_queues"
    has_many :calls,           :class_name => "Cached::Call", :dependent => :delete_all
    has_many :favorite_queues, :class_name => "Cached::FavoriteQueue"

    # def initialize(*args)
    #   debugger
    #   super
    # end
  end
end
