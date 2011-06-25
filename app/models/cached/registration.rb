# -*- coding: utf-8 -*-

module Cached
  class Registration < Base
    set_table_name "cached_registrations"
    belongs_to :software_center,  :class_name => "Cached::Center"
    belongs_to :hardware_center,  :class_name => "Cached::Center"
    has_many   :pmrs_as_owner,    :class_name => "Cached::Pmr",       :foreign_key => "owner_id"
    has_many   :pmrs_as_resolver, :class_name => "Cached::Pmr",       :foreign_key => "resolver_id"
    has_many   :queue_infos,      :class_name => "Cached::QueueInfo", :foreign_key => "owner_id"
    has_many   :queues,           :through    => :queue_infos
    has_many   :psars,            :class_name => "Cached::Psar"
    
    def personal_queue
      unless (local_queues = self.queues).empty?
        local_queues[0]
      end
    end
    once :personal_queue

  end
end
