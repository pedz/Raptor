module Cached
  class Pmr < Base
    set_table_name "cached_pmrs"
    has_many   :calls,    :class_name => "Cached::Call"
    belongs_to :owner,    :class_name => "Cached::Registration"
    belongs_to :resolver, :class_name => "Cached::Registration"
    has_many(:scratch_pad_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::SCRATCH_PAD}",
             :class_name => "Cached::TextLine",
             :order => "line_number",
             :foreign_key => "pmr_id")
    has_many(:alterable_format_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::ALTERABLE_FORMAT}",
             :class_name => "Cached::TextLine",
             :order => "line_number",
             :foreign_key => "pmr_id")
    has_many(:text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::TEXT_LINE}",
             :class_name => "Cached::TextLine",
             :order => "line_number",
             :foreign_key => "pmr_id")
    has_many(:information_text_lines,
             :conditions => "line_type = #{Cached::TextLine::LineTypes::INFORMATION_TEXT}",
             :class_name => "Cached::TextLine",
             :order => "line_number",
             :foreign_key => "pmr_id")

    def signature_lines
      self.text_lines.select { |text_line|
        text_line.text_type == :signature
      }.map { |text_line|
        Retain::SignatureLine.new(text_line.text)
      }
    end
  end
end
