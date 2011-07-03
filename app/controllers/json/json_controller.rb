# -*- coding: utf-8 -*-
module Json
  class JsonController < ApplicationController
    # Sends the item, which may be an array, as json but also calls
    # async_fetch on either the item or (in the case item is an
    # array) each element of item.
    def json_send(item, cache_options = { })
      if item.is_a? Array
        time_stamp = item.map do |c|
          get_time_stamp(c)
        end.max
      else
        time_stamp = get_time_stamp(item)
      end
      
      fresh_when(:last_modified => time_stamp, :etag => get_etag(item))
      if cache_options.has_key?(:expires_in)
        expires_in(cache_options[:expires_in])
      end
      unless request.fresh?(response)
        render :json => item
      end
    end
    
    private
    
    def get_time_stamp(c)
      if c.respond_to?(:last_fetched)
        c.last_fetched
      else
        c.updated_at
      end
    end
    
    def get_etag(item)
      case
      when item.is_a?(Array)
        item.map { |i| get_etag(i) }
      when item.respond_to?(:etag)
        item.etag
      else
        item
      end
    end
  end
end
