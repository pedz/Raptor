
module Retain
  class TextLine

    attr_accessor :line_type, :text

    def initialize(type, text)
      @line_type = type
      @text = text
    end
  end
end
