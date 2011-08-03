# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Kernel
private
   def this_method
     caller[0] =~ /`([^']*)'/ and $1
   end
end
