# -*- coding: utf-8 -*-

class CallSweeper < ActionController::Caching::Sweeper
  observe Cached::Call

  def before_update(call)
    # Rails.logger.debug("SWEEPER: call before_update called")
    return unless call.last_fetched_changed?
    kill_caches(call)
  end

  def before_destroy(call)
    # Rails.logger.debug("SWEEPER: call before_destroy called")
    kill_caches(call)
  end

  private

  # Kills the fragment caches for this call.
  def kill_caches(call)
    queue = call.queue
    queue_param = "#{queue.queue_name},#{queue.h_or_s},#{queue.center.center}"
    call_param = "#{queue_param},#{call.ppg}"
    # Rails.logger.debug("SWEEPER: kill call caches for #{call_param}")

    # Delete the fragments for each section for the call pages
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
