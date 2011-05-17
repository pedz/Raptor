module Json
  class EntitiesController < ApplicationController
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

      @nestings = group.item.nestings.find(:all, :conditions => "#{levels.item.condition.sql}")
      logger.debug(@nestings.inspect)
      render :json => @nestings.map(&:item)
    end
  end
end
