# -*- coding: utf-8 -*-

# This model is a subclass of Name so it inherits the owner field.  It
# represents a Presentation in Raptor which is a set of columns of
# type Element.  Each Element represents a column in a table.  The
# rows of the table will be the selected calls that are specified by
# the group and subselect clauses.
class Presentation < Name
  ##
  # :attr: elements
  # A has_many relation to the list of elements that this view uses.
  has_many :elements
end
