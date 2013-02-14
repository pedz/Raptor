# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # A line in a Retain format panel. Used by Retain::Field for the
  # format panel data element 631
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
      s = case @raw_text[index + 1].ord
          when 0x4f, 0x0b, 0x32; :normal_protected
          when 0x6e, 0x22; :normal_unprotected
          when 0x50, 0x3a; :intensified_protected
          when 0x4e, 0x2a; :intensified_unprotected
          else @raw_text[index + 1,1].retain_to_user
          end
      s
    end

    def raw_char(index)
      @raw_text[index + 1].ord
    end

    def trailing_line_attribute
      @raw_text[73].ord
    end
    
    def arrow_field
      @raw_text[74,4].retain_to_user
    end
    
    def line_number_count
      @raw_text[78].ord * 256 + @raw_text[79].ord
    end

    def text_line
      @raw_text[1,72].retain_to_user
    end
    
    def text_line=(new_text)
      @raw_text[1,72] = new_text.ljust(72)[1,72].user_to_retain
    end
  end
end
