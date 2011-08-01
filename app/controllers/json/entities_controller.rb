# -*- coding: utf-8 -*-

module Json
  class EntitiesController < JsonController
    def index
      json_send(::Entity.all)
    end
  end
end
