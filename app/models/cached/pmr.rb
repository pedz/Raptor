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
      to_combined.text_lines.find_all { |text_line|
        text_line.text_type == :signature
      }.map { |text_line|
        Retain::SignatureLine.new(text_line.text)
      }
    end
    once :signature_lines
    
    def signature_line_stypes(stype)
      signature_lines.find_all { |sig| sig.stype == stype }
    end
    
    # The creation_date and creation_time appear to be from the
    # perspective of the person who opened the PMR.  To get that back
    # to UTC would be really hard.  So, we find the first CE entry and
    # use its date.
    def create_time
      if (sig = signature_line_stypes('CE')).empty?
        # should never be true but just in case.
        cd = self.creation_date
        ct = self.creation_time
        # Note, the creation date and time from the PMR is in the time
        # zone of the specialist who created the PMR.  I don't know
        # how to find out who that specialist was and, even if I
        # could, I don't know his time zone.  So, I fudge and put the
        # create time according to the time zone of the customer.  So
        # this is going to be wrong sometimes.  But, it should never
        # be used anyway.
        DateTime.civil(2000 + cd[1..2].to_i, # not Y2K but who cares?
                       cd[4..5].to_i,        # month
                       cd[7..8].to_i,        # day
                       ct[0..1].to_i,        # hour
                       ct[3..4].to_i,        # minute
                       0,                    # second
                       customer.tz)          # time zone
      else
        sig.first.date
      end
    end
    once :create_time
    
    def last_ct
      signature_line_stypes('CT').last
    end
    once :last_ct

    def last_ct_time
      if (last = last_ct)
        last.date
      else
        create_time
      end
    end
    once :last_ct_time

    # age of the PMR in days
    def age
      # Note that DateTime does this subtraction correctly even if
      # they are different time zones.
      DateTime.now - create_time
    end
    once :age

  end
end
