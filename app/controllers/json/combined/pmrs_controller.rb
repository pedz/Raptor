# -*- coding: utf-8 -*-
module Json
  module Combined
    class PmrsController < Retain::RetainController
      def show
        render :json => ::Combined::Pmr.find(params[:id])
      end
    end
  end
end
