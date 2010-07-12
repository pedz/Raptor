module Json
  module Combined
    class CallsController < Retain::RetainController
      def index
        render :json => ::Combined::Queue.find(params[:queue_id]).calls
      end

      def show
        render :json => ::Combined::Call.find(params[:id])
      end
    end
  end
end
