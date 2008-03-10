module Retain
  class QueueController < RetainController
    def show
      if @queue = Combined::Queue.from_param(params[:id], method(:signon_user))
        @queue.mark_cache_invalid
        @calls = @queue.calls
      else
        render :text => "<h2 style='color:red'>Queue not found</h2>"
      end
    end
  end
end
