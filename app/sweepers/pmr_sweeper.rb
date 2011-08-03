# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class PmrSweeper < ActionController::Caching::Sweeper
  observe Cached::Pmr

  def before_update(pmr)
    # Rails.logger.debug("SWEEPER: pmr before_update called")
    return unless pmr.last_fetched_changed?
    kill_caches(pmr)
  end

  def before_destroy(pmr)
    # Rails.logger.debug("SWEEPER: pmr before_destroy called")
    kill_caches(pmr)
  end

  private

  # Kills the fragment caches for this pmr.
  def kill_caches(pmr)
    # Rails.logger.debug("SWEEPER: kill pmr caches for #{pmr.problem},#{pmr.branch},#{pmr.country}")
    pmr.calls.map do |call|
      queue = call.queue
      queue_param = "#{queue.queue_name},#{queue.h_or_s},#{queue.center.center}"
      call_param = "#{queue_param},#{call.ppg}"
      [ 'top', 'center', 'left', 'right' ].each do |section|
        expire_fragment(:controller => 'retain/call',
                        :host => 'raptor_host',
                        :action => :show,
                        :id => call_param,
                        :action_suffix => section)
      end
      
      # Now delete the qs fragment
      expire_fragment(:controller => 'retain/qs',
                      :host => 'raptor_host',
                      :action => :show,
                      :id => queue_param,
                      :action_suffix => call.ppg)
    end
  end
end
