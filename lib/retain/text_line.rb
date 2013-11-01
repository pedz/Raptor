# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

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
      # Rails.logger.debug("Retain::TextLine#initialize ccsid = #{ccsid}")
      super()
      @text_type = @@special_line[text[0].ord]
      cs = Ccsid.to_cs(ccsid)

      if @text_type != :normal
        #
        # In the case of text lines with the special byte in the first
        # byte, we change it to a space.  The space is in the same code
        # space that we are coming from.  NOTE: We do not want to do the
        # to_u with this ugly byte because it might confuse the
        # converter.  So we need to stomp on it before the to_u.
        #
        text = text.dup
        text[0] = ' '.to_u.to_s(cs)
      end
      begin
        @text = text.retain_to_user(cs)
      rescue ArgumentError
        Rails.logger.debug("cs is #{cs}")
        @text = text.retain_to_user
      end
    end
  end
end
