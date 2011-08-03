# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Json
  class EntitiesController < JsonController
    def index
      json_send(::Entity.all)
    end
  end
end
