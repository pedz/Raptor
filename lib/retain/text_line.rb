
module Retain
  class TextLine

    @@special_line = Array.new(256, :normal)
    @@special_line[0x22] = :normal_unprotected
    @@special_line[0x2a] = :intensified_unprotected
    @@special_line[0x32] = :normal_protected
    @@special_line[0x3a] = :intensified_protected
    @@special_line[0x3d] = :system_inserted
    @@special_line[0x3f] = :signature

    attr_accessor :text_type, :text

    def self.blank_lines(n)
      Array.new(n, TextLine.new(' ' * 72, 1208))
    end

    def initialize(text, ccsid)
      @text_type = @@special_line[text[0]]
      cs = Ccsid.to_cs(ccsid)

      if @text_type == :normal
        @text = text.to_u(cs).to_s("utf8")
      else
        #
        # In the case of text lines with the special byte in the first
        # byte, we change it to a space.  The space is in the same code
        # space that we are coming from.  NOTE: We do not want to do the
        # to_u with this ugly byte because it might confuse the
        # converter.  So we need to stomp on it before the to_u.
        #
        text = text.dup
        text[0] = ' '.to_u.to_s(cs)

        #
        # The signature has nulls in it.  So we do a gsub while in
        # UTF-16.  I am guessing it is safer to do the substitution
        # while in UTF-16 than as a string since the Strings.gsub does
        # not know about double byte codes (and may replayce the space
        # that shows up as the second byte in a double byte sequence).
        #
        # The icu4r had some problems here.  /\0/.U seems to cause a
        # core dump.  The "\0".to_u has the proper effect and avoids the
        # core dump.  (Its probably cheaper to create too).
        text = text.to_u(cs).gsub("\0".to_u, ' '.to_u)
        @text = text.to_s("utf8")
      end
    end
  end
end
