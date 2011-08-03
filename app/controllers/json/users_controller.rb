# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Json
  class UsersController < JsonController
    def index
      json_send(User.all)
    end

    def show
      json_send(User.find(params[:id]))
    end
  end
end
