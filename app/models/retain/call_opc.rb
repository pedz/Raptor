# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class CallOpc
    attr_reader   :call
    
    # The call can be a call or a PMR
    def initialize(call)
      @call = call
      @opc = Opc.new(@call)
    end

    def to_id
      @_to_id ||= @opc.to_id
    end

    def id
      @_id ||= @opc.id
    end
    
    def to_param
      @_to_param ||= @opc.to_param
    end
  end
end
