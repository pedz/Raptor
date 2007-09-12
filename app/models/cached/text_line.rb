class Cached::TextLine < ActiveRecord::Base
  set_table_name "cached_text_lines"
  belongs_to(:cached_pmr,
             :class_name => "Cached::Pmr",
             :foreign_key => "cached_pmr_id",
             :order => "line_number ASC")
end
