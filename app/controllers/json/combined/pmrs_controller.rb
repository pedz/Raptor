# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class PmrsController < Retain::RetainController
      def show
        render :json => ::Combined::Pmr.find(params[:id])
      end
    end
  end
end
