# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class CallFi5312
    attr_reader   :call
    attr_accessor :line_1
    attr_accessor :line_2
    attr_accessor :line_3
    attr_accessor :next_action_owner
    attr_accessor :day
    attr_accessor :month
    attr_accessor :year
    
    def initialize(call)
      @call = call
      @next_action_owner = "DSS"
      date = Date.tomorrow
      @day = date.strftime("%d")
      @month = date.strftime("%m")
      @year = date.strftime("%Y")
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
  end
end
