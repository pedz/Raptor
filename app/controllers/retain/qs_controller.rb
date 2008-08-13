module Retain
  class QsController < RetainController
    def show
      @todays_psars = signon_user.psars.today.group_by(&:pmr_id).inject({ }) do |memo, a|
        memo[a[0]] = a[1]
        memo
      end
      logger.debug("CNT: qs#show #{@todays_psars.inspect}")
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
