# -*- coding: utf-8 -*-
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
