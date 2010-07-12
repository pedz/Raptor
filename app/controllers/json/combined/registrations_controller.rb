module Json
  module Combined
    class RegistrationsController < Retain::RetainController
      def index
        render :json => ::Combined::Registration.find(:all)
      end

      def show
        render :json => ::Combined::Registration.find(params[:id])
      end
    end
  end
end
