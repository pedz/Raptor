module Retain
  class QsController < RetainController
    def show
      if (@queue = Combined::Queue.from_param(params[:id]))
        @queue.mark_cache_invalid
      else
        render :text => "<h2 style='color:red'>Queue not found</h2>"
      end
    end
  end
end
