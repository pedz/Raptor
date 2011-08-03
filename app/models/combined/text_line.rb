# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # Combined TextLine Model
  class TextLine < Combined::Base
    ##
    # :attr: expire_time
    # Set to :never
    set_expire_time :never

    ##
    # The param for a text line is its database id as a string.
    def to_param
      @cached.id.to_s
    end

  end
end
