# -*- coding: utf-8 -*-

# This model is a subclass of Name so it inherits the owner field.  It
# represents a View in Raptor which is a set of columns of type
# Element.  Each Element represents a column in a table.  The rows of
# the table will be the selected calls that are specified by the group
# level, and filter options.
#
# A problem that has not been addressed yet is the concept of views
# for calls and views for queues.
class View < Name
  ##
  # :attr: elements
  # A has_many relation to the list of type Element that this view uses.
  has_many :elements
  has_many :widgets, :through => :elements

  def widget_names
    self.widgets.map { |widget| widget.name }
  end
end
