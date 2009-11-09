# -*- coding: utf-8 -*-

module Retain
  class QsController < RetainController
    def show
      # Throw an exception if the queue is not valid early on
      @queue = Combined::Queue.from_param!(params[:id], signon_user)

      # If we had to use some default somewhere, lets redirect so that
      # the path is fully qualified and uppercase.
      if @queue.to_param != params[:id]
        redirect_to(:id => @queue.to_param)
        return
      end

      # If @no_cache is set, the db calls are dumped.  This will cause
      # all but the pmrs to be fetched and also cause last_fetched to
      # change.  In the case of the PMRs, it is possible for them to
      # not be updated but we will ask Retain in the process that our
      # copy is in deed up to date.
      if @no_cache
        @queue.mark_pmrs_as_dirty
        @queue.calls.clear
        @queue.mark_as_dirty
      end

      # We suck all the calls and pmrs in, touching each.  If anything
      # is re-fetched it will update the queues last_fetched time.
      begin
        fetch_all_calls(@queue)
      rescue
        # a stale call caused an exception so we mark the queue as
        # dirty and try again.  This will query retain for the valid
        # list of calls and fix everything up.
        @queue.mark_as_dirty
        # if this raises an exception, I want to see it for now
        fetch_all_calls(@queue)
        
        # possible action if above throws an exception... otherwise we
        # want to delete this because the view is no longer used.
        #
        # render "shared/retain/sdi", :layout => false
        #
      end

      last_fetched = (@queue.last_fetched || Time.now)
      fresh_when(:last_modified => last_fetched, :etag => @queue.etag)
      
      if !request.fresh?(response)
        # Fetch the psar values if we are going to redraw things.
        @todays_psars = signon_user.psars.today.group_by(&:pmr_id).inject({ }) do |memo, a|
          memo[a[0]] = a[1]
          memo
        end
      end
    end

    private

    def fetch_all_calls(queue)
      queue.calls.each { |call|
        # Need to fetch a non-constant piece of the call.  The PMR is
        # a constant.
        call.comments
        call.severity
      }
    end
  end
end
