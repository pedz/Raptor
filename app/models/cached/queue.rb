module Cached
  class Queue < Base
    set_table_name "cached_queues"
    belongs_to :center,          :class_name => "Cached::Center"
    has_many   :calls,           :class_name => "Cached::Call",      :dependent => :delete_all, :order => "slot"
    has_many   :favorite_queues, :class_name => "Cached::FavoriteQueue"
    has_many   :next_queue_pmrs, :class_name => "Cached::Pmr",       :foreign_key => "next_queue_id"
    has_many   :queue_infos,     :class_name => "Cached::QueueInfo", :foreign_key => "queue_id"
    has_many   :owners,          :through    => :queue_infos
    has_many   :psars,           :class_name => "Cached::Psar"

    def self.team_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        q.team_queue?
      }
    end

    def self.personal_queues
      self.find(:all,
                :include => :owners,
                :order => "queue_name, h_or_s").select { |q|
        not q.team_queue?
      }
    end

    def team_queue?
      self.owners.empty?
    end
  end
end
