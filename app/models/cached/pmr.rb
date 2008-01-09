module Cached
  class Pmr < Base
    set_table_name "cached_pmrs"
    has_many :calls, :class_name => "Cached::Call"
    has_many :text_lines, :class_name => "Cached::TextLine", :foreign_key => "cached_pmr_id"
  end
end
