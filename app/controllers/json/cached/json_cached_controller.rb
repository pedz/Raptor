# -*- coding: utf-8 -*-
module Json
  module Cached
    class JsonCachedController < ApplicationController
      # Sends the item, which may be an array, as json but also calls
      # async_fetch on either the item or (in the case item is an
      # array) each element of item.
      def json_send(item)
        if item.is_a? Array
          item.each { |c| async_fetch(c) }
        else
          async_fetch(item)
        end
        render :json => item
      end
    end
  end
end
