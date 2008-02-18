module Cached
  class Registration < Base
    set_table_name "cached_registrations"
    has_many :pmrs_as_owner,    :class_name => "Cached::Pmr",       :foreign_key => "owner_id"
    has_many :pmrs_as_resolver, :class_name => "Cached::Pmr",       :foreign_key => "resolver_id"
    has_many :queue_infos,      :class_name => "Cached::QueueInfo", :foreign_key => "owner_id"
    has_many :queues,           :through    => :queue_infos
  end
end
