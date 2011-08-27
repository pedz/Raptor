# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Json
  class GeneralController < JsonController
    def index
      begin
        json_send(walk_path)
      rescue Exception => e
        logger.error("URL Error: #{request.env["REQUEST_URI"]}")
        logger.debug(e.message)
        logger.debug(e.backtrace.join("\n"))
        render :json => 'Not Found', :status => 404
      end
    end

    def show
      begin
        json_send(walk_path)
      rescue Exception => e
        logger.error("URL Error: #{request.env["REQUEST_URI"]}")
        logger.debug(e.message)
        logger.debug(e.backtrace.join("\n"))
        render :json => 'Not Found', :status => 404
      end
    end
  end
end
