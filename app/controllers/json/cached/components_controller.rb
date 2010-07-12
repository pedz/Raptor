module Json
  module Cached
    class ComponentsController < Retain::RetainController
      def index
        render :json => ::Cached::Component.find(:all)
      end

      def show
        render :json => ::Cached::Component.find(params[:id])
      end
    end
  end
end
