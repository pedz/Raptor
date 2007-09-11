
module Retain
  class TextLine

    attr_accessor :type, :text

    def initialize(type, text)
      @type = type
      @text = text
    end
  end
end
