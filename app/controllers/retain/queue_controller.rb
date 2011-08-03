# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class QueueController < RetainController
    def show
      @queue = Combined::Queue.from_param!(params[:id], signon_user)
      @queue.mark_cache_invalid
      @calls = @queue.calls
    end
  end
end
