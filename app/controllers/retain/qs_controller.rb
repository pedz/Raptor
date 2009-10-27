# -*- coding: utf-8 -*-

module Retain
  class QsController < RetainController
    def show
      @queue = Combined::Queue.from_param!(params[:id], signon_user)
      # If we had to use some default somewhere, lets redirect so that
      # the path is fully qualified and uppercase.
      if @queue.to_param != params[:id]
        redirect_to(:id => @queue.to_param)
        return
      end

      # We suck all the calls and pmrs in, touching each.  If anything
      # is re-fetched it will update the queues last_fetched time.
      @queue.calls.each { |call| call.pmr.severity }

      loop = 0
      while true
        begin
          last_fetched = (@queue.last_fetched || Time.now)
          # This loop could be avoided by updating the last_fetched
          # timestamp of the calls and queues whenever a call or PMR
          # changed.
          #
          # We should also be able to avoid the loop if the queue is
          # dirty since, in that case, we know that something has
          # changed.
          @queue.calls.each do |call|
            # touch the call and pmr to cause an update if needed
            call.priority
            call.pmr.severity
            
            if last_fetched < call.last_fetched
              last_fetched = call.last_fetched
            end
            pmr = call.pmr
            if last_fetched < pmr.last_fetched
              last_fetched = pmr.last_fetched
            end
          end
          
          fresh_when(:last_modified => last_fetched, :etag => @queue.etag)
          
          if !request.fresh?(response)
            @todays_psars = signon_user.psars.today.group_by(&:pmr_id).inject({ }) do |memo, a|
              memo[a[0]] = a[1]
              memo
            end
            if @no_cache
              logger.debug("marking queue and calls as invalid")
              @queue.mark_cache_invalid
              @queue.calls.each { |call| call.pmr.mark_cache_invalid }
            end
          end
          break
          
        rescue Combined::CallNotFound => e
          # We are going to assume the queue is invalid and try again.
          loop += 1
          if loop >= 3
            render "shared/retain/sdi", :layout => false
            break
          end
          @queue.mark_cache_invalid
          
        rescue Retain::SdiReaderError => e
          loop += 1
          if @queue.is_invalid? || loop >= 3
            render "shared/retain/sdi", :layout => false
            break
          end
          @queue.mark_cache_invalid
        end
      end
    end
  end
end
