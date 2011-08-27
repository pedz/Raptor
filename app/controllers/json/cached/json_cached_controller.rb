# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Json
  module Cached
    class JsonCachedController < JsonController
      def json_send(item, cache_options = { })
        if item.is_a? Array
          item.each do |c|
            async_fetch(c)
          end
        else
          async_fetch(item)
        end
        # Note that this controller is a subclass of JsonController.
        # JsonController has included JsonCommon so this super goes to
        # the json_send in JsonCommon
        super(item, cache_options)
      end
    end
  end
end
