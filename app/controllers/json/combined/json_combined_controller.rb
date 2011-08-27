# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Combined
    # Note that unlike JsoCachedController, JsonCombinedController
    # does *not* inherit from JsonController but RetainController
    # instead in order to give the Combined module access to Retain.
    # Thus, json_send goes to the method in JsonCommon
    class JsonCombinedController < Retain::RetainController
      include JsonCommon
    end
  end
end
