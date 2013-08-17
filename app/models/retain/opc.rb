# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class Opc
    attr_reader   :item
    
    # The item can be a call or a PMR
    def initialize(item)
      @item = item
    end

    def to_id
      @_to_id ||= @item.to_id
    end

    def id
      @_id ||= @item.id
    end
    
    def to_param
      @_to_param ||= @item.to_param
    end
  end
end
