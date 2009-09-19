module Retain
  class ComponentsController < RetainController
    def show
      # @component = Retain::Component.new(:search_component_id => params[:id])
      @component = Retain::Component.new(:short_component_id => params[:id])
      @component.send(:component_name)
    end
  end
end
