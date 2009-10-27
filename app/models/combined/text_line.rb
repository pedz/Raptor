# -*- coding: utf-8 -*-

module Combined
  class TextLine < Base

    set_expire_time :never

    def to_param
      @cached.id.to_s
    end

  end
end
