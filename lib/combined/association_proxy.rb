# -*- coding: utf-8 -*-

module Combined
  class AssociationProxy
    cattr_accessor :logger
    include Common
    
    def initialize(object)
      @cached = object
    end

    def mark_cache_invalid
      @invalid_cache = true
    end

    def cached
      return @cached
    end

    def unwrap_to_cached
      @cached
    end
  end
end
