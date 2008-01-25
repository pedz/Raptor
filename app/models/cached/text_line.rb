module Cached
  class TextLine < Base
    module LineTypes
      TEXT_LINE = 0
      SCRATCH_PAD = 1
      ALTERABLE_FORMAT = 2
      INFORMATION_TEXT = 3
    end

    @@text_type_ord_to_text_type = [
                                    :normal,
                                    :normal_unprotected,
                                    :intensified_unprotected,
                                    :normal_protected,
                                    :intensified_protected,
                                    :system_inserted,
                                    :signature
                                   ]
    @@text_type_to_text_type_ord = Hash[* (i = -1;
                                           @@text_type_ord_to_text_type.map {
                                             |e| [ e, i += 1 ]
                                           }.flatten) ]
    set_table_name "cached_text_lines"
    belongs_to(:pmr,
               :class_name => "Cached::Pmr",
               :foreign_key => "pmr_id",
               :order => "line_number ASC")

    # The public interface has text_type.  We map it to an integer
    # when we go to and from the database.
    def text_type=(value)
      self.text_type_ord = @@text_type_to_text_type_ord[value]
    end

    def text_type
      @@text_type_ord_to_text_type[self.text_type_ord]
    end
  end
end
