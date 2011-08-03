# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# Level is the model that represents what levels to display.  For
# example, in the URL calls/top/xxx/yyy/zzz, "top" is the Level and
# will specify that only the top level items in the container, those
# with nesting level of one, should be displayed.
class Level < Name
  ##
  # :attr: condition
  # A has_one relation to a Condition.  By convention, this Condition
  # will be a restriction on "level".
  has_one :condition, :foreign_key => :name_id
  accepts_nested_attributes_for :condition
end
