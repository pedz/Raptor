module Retain
  class FormatPanelLine
    def initialize(raw_text)
      @raw_text = raw_text
    end

    def leading_line_attribute
      @raw_text[0].ord
    end
    
    def leading_line_attribute=(value)
      @raw_text[0] = value.chr
    end
    
    def char(index)
      s = case @raw_text[index + 1]
          when 0x4f, 0x0b, 0x32; :normal_protected
          when 0x6e, 0x22; :normal_unprotected
          when 0x50, 0x3a; :intensified_protected
          when 0x4e, 0x2a; :intensified_unprotected
          else @raw_text[index + 1,1].retain_to_user
          end
      s
    end

    def text_line
      @raw_text[1,72].retain_to_user
    end
    
    def text_line=(new_text)
      @raw_text[1,72] = new_text.ljust(72)[1,72].user_to_retain
    end
  end
end
