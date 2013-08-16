# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class PmrOpc
    attr_reader   :pmr
    
    # The pmr can be a pmr or a PMR
    def initialize(pmr)
      @pmr = pmr
      @opc = Opc.new(@pmr)
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
