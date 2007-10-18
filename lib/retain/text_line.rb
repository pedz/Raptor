
module Retain
  class TextLine

    attr_accessor :line_type, :text, :code_page

    def self.blank_lines(n)
      Array.new(n, TextLine.new(34, ' ' * 72, 86))
    end

    def initialize(type, text, code_page)
      @line_type = type
      @text = text
      @code_page = code_page
    end
  end
end
