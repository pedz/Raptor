# -*- coding: utf-8 -*-

# This model is a subclass of Name so it inherits the owner field.  It
# represents a "view" in Raptor which is a set of elements.  Each
# element represents a column in a table.  The rows of the table will
# be the selected calls that are specified by the group and subselect
# clauses.
class View < Name
  ##
  # :attr: elements
  # A has_many relation to the list of elements that this view uses.
  has_many :elements
end
