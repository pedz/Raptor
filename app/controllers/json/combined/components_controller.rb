# -*- coding: utf-8 -*-
module Json
  module Combined
    class ComponentsController < Retain::RetainController
      def index
        render :json => ::Combined::Component.find(:all)
      end

      def show
        render :json => ::Combined::Component.find(params[:id])
      end
    end
  end
end
