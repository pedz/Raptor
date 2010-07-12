module Json
  module Combined
    class QueuesController < Retain::RetainController
      def show
        render :json => ::Combined::Queue.find(params[:id])
      end
    end
  end
end
