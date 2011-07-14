# -*- coding: utf-8 -*-

module Cached
  # === Retain Text Line Model
  #
  # A Retain text line comes in four different places.
  class TextLine < Base
    ##
    # :attr: id
    # The primary key for the table.

    ##
    # :attr: pmr_id
    # The id from the cached_pmrs for the PMR associated with this
    # text line.

    ##
    # :attr: line_type
    # The line type for this text line.  See LineTypes

    ##
    # :attr: line_number
    # The line number for the line.  For a given PMR and line_type,
    # this is unique.

    ##
    # :attr: text_type_ord
    # A text line has a type of :normal (0), :normal_unprotected (1),
    # :intensified_unprotected (2), :normal_protected (3),
    # :intensified_protected (4), :system_inserted (5), and :signature
    # (6).  In Raptor, the symbols are used.  As the text line is
    # pushed out to the database or retrieved back, it is converted to
    # or from a simple integer.  The first byte of the text line
    # retrieved from Retain determines its type.

    ##
    # :attr: text
    # The actual text of the text line.

    ##
    # :attr: created_at
    # Rails normal created_at timestamp that is when the db record was
    # created.

    ##
    # :attr: updated_at
    # Rails normal updated_at timestamp.  Each time the db record is
    # saved, this gets updated.

    # The four areas where a text line can appear.
    module LineTypes
      ##
      # The lines in a PMR except for the FA and scratch pad lines.
      TEXT_LINE = 0

      ##
      # The scratch pad lines.
      SCRATCH_PAD = 1

      ##
      # The lines from the Form Alter
      ALTERABLE_FORMAT = 2

      ##
      # The text that has the entitlement and other things.  This is
      # not seen in the PMR itself.
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

    ##
    # :attr: pmr
    # A belongs_to association to the Cached::Pmr this text line is
    # for.
    belongs_to(:pmr,
               :class_name => "Cached::Pmr",
               :foreign_key => "pmr_id")

    ##
    # A regular expression that matches the text of a service given
    # line.
    SERVICE_GIVEN_REGEXP = Regexp.new("SERVICE GIVEN= ([1234]9)")
    ##
    # If the text line is a service given line, returns the value of
    # the service given.
    def service_given
      if (md = SERVICE_GIVEN_REGEXP.match(self.text))
        md[1]
      end
    end
    once :service_given

    ##
    # The public interface has text_type.  We map it to an integer
    # when we go to and from the database.
    def text_type=(value)
      self.text_type_ord = @@text_type_to_text_type_ord[value]
    end

    ##
    # The getter for text_type
    def text_type
      @@text_type_ord_to_text_type[self.text_type_ord]
    end
  end
end
