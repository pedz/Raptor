module Cached
  class Call < Base
    set_table_name "cached_calls"
    belongs_to :queue, :class_name => "Cached::Queue"
    belongs_to :pmr, :class_name => "Cached::Pmr"
    
    def to_combined
      Combined::Call.new(self)
    end
  end
end
