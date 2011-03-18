# -*- coding: utf-8 -*-

# = Element
#
# An element is a piece of a view.  A view will be rendered as an HTML
# table which will have rows and columns.  An element has the rowspan
# and colspan attributes and so will consume those rows and columns in
# the HTML table.  What is put into that area is deteremined by the
# javascript code associated with the widget that the element
# referenes.
#
# ==Fields
# <em>id - integer</em>:: Key for the table
# <em>widget_id - integer</em>:: Which widget is referenced
# <em>view_id - integer</em>:: Which view the element is part of.
# <em>owner_id - integer</em>:: Owner of the element.
# <em>row - integer</em>:: Which row the element starts on.
# <em>column - integer</em>:: Which column the element starts on.
# <em>rowspan - integer</em>:: The number of rows the element will span.
# <em>colspan - integer</em>:: The number of columsn the element will span.
class Element < ActiveRecord::Base
  belongs_to :view
  belongs_to :widget
  belongs_to :owner, :class_name => "User"
  validates_uniqueness_of :col, :scope => [ :view_id, :row ], :message => "[ View, row, col ] must be unique"
end
