# -*- coding: utf-8 -*-
module Json
  class CallsController < ApplicationController
    # The first request sent back by the calls request is to this
    # controller and it should return the list of calls on the queues
    # that have been specified by the group, levels, and filter
    # parameters.
    def index
      group = params[:group]
      levels = params[:levels]
      filter = params[:filter]
      group = Entity.find_by_name(group)
      levels = Entity.find_by_name(levels)
      filter = Entity.find_by_name(filter)

      nestings = group.item.nestings.
        find(:all, :conditions => "(#{levels.item.condition.sql}) AND (item_type = 'Cached::Queue')")
      queue_ids = nestings.map(&:item_id)

      # There may be a better way to do this but for now, I'm just
      # going to fetch the queues and then ask them to be fetched.
      Cached::Queue.find(:all, :conditions => { :id => queue_ids }).each do |q|
        other_name(q)
      end

      calls = Cached::Call.scoped(:conditions => { :queue_id => queue_ids }).
        scoped(:include => [:pmr, :queue]).scoped(:conditions => filter.item.condition.sql)
      render :json => {
        :class_name => "Cached::Call",
        :calls => calls.map do |call|
          other_name(call)
          call.as_json
        end
      }
    end

    # Fetches the object -- which is expected to be a subclass of
    # Cached::Base -- asynchronously using the worker tasks.  This
    # can't be a method of the model because it needs to
    # application_user.
    #
    # calls Cached::Base#async_priority to determine the priority of
    # the request.
    def other_name(obj, force = false)
      pri = obj.async_priority
      return if pri == :none
      AsyncRequest.new(application_user.current_retain_id.id, obj).
        async_send(:fetch, :pri => pri)
    end
  end
end
