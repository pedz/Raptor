module Json
  module Cached
    class CentersController < Retain::RetainController
      def index
        render :json => ::Cached::Center.find(:all)
      end

      def show
        render :json => ::Cached::Center.find(params[:id])
      end
    end
  end
end
