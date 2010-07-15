module Json
  module Cached
    class QueuesController < Retain::RetainController
      def show
        render :json => ::Cached::Queue.find(params[:id]).as_json(:include => [ :calls ])
      end
    end
  end
end
