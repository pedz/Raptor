module Retain
  class QsController < RetainController
    def show
      if @queue = Combined::Queue.from_param!(params[:id])
        unless @refresh_time.nil?
          @queue.mark_cache_invalid
          @queue.calls.each { |call| call.pmr.mark_cache_invalid }
        end
      else
        render :text => "<h2 style='color:red'>Queue not found</h2>"
      end
    end
  end
end
