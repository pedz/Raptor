module Retain
  class QueueController < RetainController
    def show
      @queue = Combined::Queue.from_param(params[:id])
      @queue.mark_cache_invalid
      @calls = @queue.calls
    end
  end
end
