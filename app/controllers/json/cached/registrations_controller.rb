module Json
  module Cached
    class RegistrationsController < Retain::RetainController
      def index
        render :json => ::Cached::Registration.find(:all,
                                                    :conditions => { :apptest => Logon.instance.apptest})
      end

      def show
        render :json => ::Cached::Registration.find(params[:id])
      end
    end
  end
end
