module Cached
  class Pmr < Base
    set_table_name "cached_pmrs"
    has_many   :calls,    :class_name => "Cached::Call"
    belongs_to :owner,    :class_name => "Cached::Registration"
    belongs_to :resolver, :class_name => "Cached::Registration"
    belongs_to :customer, :class_name => "Cached::Customer"
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
      @sig_lines ||= self.text_lines.select { |text_line|
        text_line.text_type == :signature
      }.map { |text_line|
        Retain::SignatureLine.new(text_line.text)
      }
    end
    
    def signature_line_stypes(stype)
      signature_lines.select { |sig| sig.stype == stype }
    end
    
    def create_time
      cd = self.creation_date
      ct = self.creation_time
      Time.mktime(cd[1..2], cd[4..5], cd[7..8], ct[0..1], ct[3..4])
    end
    
    def last_ct
      signature_line_stypes('CT').last
    end

    def last_ct_time
      if (last = last_ct)
        last.date
      else
        create_time
      end
    end
    
    # age of the PMR in days -- not truncated
    def age
      (Time.now - create_time) / 86400
    end
  end
end
