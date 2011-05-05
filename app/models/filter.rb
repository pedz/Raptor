# -*- coding: utf-8 -*-

# Filter is a named set containing elements of type Condition that
# filters the set of calls or queues passed to the browser.
class Filter < Name
  ##
  # :attr: conditions
  # A has_many association of type Condition.  (should this be just a
  # has one? association?)
  has_many :conditions
end
