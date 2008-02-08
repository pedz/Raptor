module Retain
  class QsController < RetainController
    def show
      @queue = Combined::Queue.from_param(params[:id])
      @queue.mark_cache_invalid
    end
  end
end
