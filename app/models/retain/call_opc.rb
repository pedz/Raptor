# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class CallOpc
    # The call can be a call or a PMR
    def initialize(call)
      @call = call
      @opc = Opc.new(call)
      @pmr_opc = PmrOpc.new(@call.pmr)
    end

    def to_id
      @_to_id ||= @call.to_id
    end

    def id
      @_id ||= @call.id
    end
    
    def to_param
      @_to_param ||= @call.to_param
    end

    def update(opc_options)
      @pmr_opc.update(opc_options)
    end

    def opc
      @opc
    end
  end
end
