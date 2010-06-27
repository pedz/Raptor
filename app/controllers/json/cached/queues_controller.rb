module Json
  module Cached
    class QueuesController < Retain::RetainController
      def show
        render :json => ::Cached::Queue.find(params[:id])
      end
    end
  end
end
