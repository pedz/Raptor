# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Combined
  # Combined QueueInfo Model
  #
  # This is here simply because we want to be able to go from
  # Combined::Queue to a Combined::Registration or vice versa.
  class QueueInfo < Combined::Base
    ##
    # Returns the database id as a string.
    def to_param
      @cached.id.to_s
    end
    
    ##
    # Need to define this even though it doesn't do anything
    def load
    end
  end
end
