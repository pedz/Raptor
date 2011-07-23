# -*- coding: utf-8 -*-
module Json
  class RetusersController < JsonController
    def index
      logger.debug("Params = #{params.inspect}")
      logger.debug("params[:user_id] = #{params[:user_id]}")
      if (user_id = params[:user_id])
        logger.debug("HERE!!")
        json_send(User.find(user_id).retusers.all)
      else
        json_send(Retuser.all)
      end
    end

    def show
      if (user_id = params[:user_id])
        json_send(User.find(user_id).retusers.find(params[:id]))
      else
        json_send(Retuser.find(params[:id]))
      end
    end
  end
end
