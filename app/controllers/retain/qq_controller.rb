# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class QqController < RetainController
    #
    # Mostly test and debug code.  This does a "qq" call which gets
    # some characteristics of a queue.  I could not find anything
    # useful here.
    #
    def show
      fields = params[:id].split(',')
      queue_name = fields.shift
      if fields.length > 1
        h_or_s = fields[0]
        center = fields[1]
      else
        center = fields[0]
        h_or_s = 'S'
      end
      options = {
        :queue_name => queue_name.upcase.strip,
        :h_or_s => h_or_s,
        :center => center,
      }
      @query = Retain::Qq.new(retain_user_connection_parameters, options)
    end
  end
end
