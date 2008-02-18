module Cached
  class Queue < Base
    set_table_name "cached_queues"
    has_many :calls,           :class_name => "Cached::Call",      :dependent => :delete_all
    has_many :favorite_queues, :class_name => "Cached::FavoriteQueue"
    has_many :queue_infos,     :class_name => "Cached::QueueInfo", :foreign_key => "queue_id"
    has_many :owners,          :through    => :queue_infos

    # def initialize(*args)
    #   debugger
    #   super
    # end
  end
end
