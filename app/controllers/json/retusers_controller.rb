# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Json
  class RetusersController < JsonController
    def index
      if (user_id = params[:user_id])
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
