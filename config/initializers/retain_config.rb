# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# Add site specific configuration here

module RetainConfig
  # Which node should we use
  NodeIndex = 0
  # NodeIndex = 1
  HARDWARE_NODES = [ :ral, :sf2 ]
  SOFTWARE_NODES = [ :bdc, :rta ]
end
