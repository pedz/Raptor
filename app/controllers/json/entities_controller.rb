module Json
  class EntitiesController < ApplicationController
    logger.debug("LOADED")

    def index
      group = params[:group]
      levels = params[:levels]
      filter = params[:filter]
      logger.debug("group=#{group} levels=#{levels}, filter=#{filter}")
      group = Entity.find_by_name(group)
      level = Entity.find_by_name(level)
      filter = Entity.find_by_name(filter)

      @entities = Nesting.find_all_by_name(params[:group], :conditions => "(#{level.item.condition}) AND (#{filter.item.condition})")
      render :text => "hi", :layout => false
    end
  end
end
