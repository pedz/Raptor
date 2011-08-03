# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # An ActiveRecord assocation uses a proxy and this is a similar
  # concept.  For associations that act like an array, a Proxy is used
  # as the wrapper.
  class AssociationProxy
    # Initialized in config/initializers/loggers.rb
    cattr_accessor :logger
    include Common
    
    # Simply saves object as @cached.
    def initialize(object)
      @cached = object
    end

    # Sets the invalide_cache attribute
    def mark_cache_invalid
      @invalid_cache = true
    end

    # Returns the original object
    def unwrap_to_cached
      @cached
    end
  end
end
