class Cached::Pmr < ActiveRecord::Base
  set_table_name "cached_pmrs"
  has_many :cached_text_lines, :class_name => "Cached::TextLine", :foreign_key => "cached_pmr_id"
end
