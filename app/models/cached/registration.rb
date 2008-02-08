module Cached
  class Registration < Base
    set_table_name "cached_registrations"
    has_many :pmrs_as_owner,    :foreign_key => "owner_id",    :class_name => "Cached::Pmr"
    has_many :pmrs_as_resolver, :foreign_key => "resolver_id", :class_name => "Cached::Pmr"
  end
end
