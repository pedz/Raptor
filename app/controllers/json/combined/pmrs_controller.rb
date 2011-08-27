# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    class PmrsController < JsonCombinedController
      def index
        @options = params
        @controller = @options.delete(:controller)
        @action = @options.delete(:action)
        logger.debug(@options)
        if @options.keys.length > 0
          json_send(::Combined::Pmr.find(:all, :conditions => @options))
        else
          render :json => "Illegal Request", :status => 403
        end
      end

      def show
        json_send(::Combined::Pmr.find(params[:id]))
      end
    end
  end
end
