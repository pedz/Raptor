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
      logger.debug("group=#{group} levels=#{levels}, filter=#{filter}")
      group = Entity.find_by_name(group)
      levels = Entity.find_by_name(levels)
      filter = Entity.find_by_name(filter)
      logger.debug(group.inspect)
      logger.debug(levels.inspect)
      logger.debug(filter.inspect)

      nestings = group.item.nestings.find(:all, :conditions => "(#{levels.item.condition.sql}) AND (item_type = 'Cached::Queue')")
      logger.debug("HI")
      queue_ids = nestings.map(&:item_id)
      logger.debug("THERE")
      calls = Cached::Call.scoped(:conditions => { :queue_id => queue_ids }).scoped(:include => :pmr).scoped(:conditions => filter.item.condition.sql)
      render :json => calls
    end
  end
end