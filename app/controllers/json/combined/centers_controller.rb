# -*- coding: utf-8 -*-
module Json
  module Combined
    class CentersController < Retain::RetainController
      def index
        render :json => ::Combined::Center.find(:all)
      end

      def show
        render :json => ::Combined::Center.find(params[:id])
      end
    end
  end
end
