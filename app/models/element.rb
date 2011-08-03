# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# An element is a piece of a view.  A view will be rendered as an HTML
# table which will have rows and columns.  An element has rowspan and
# colspan attributes and so will consume those rows and columns in the
# HTML table.  What is put into that area is deteremined by the
# javascript code associated with the Widget that the element
# referenes.
#
class Element < ActiveRecord::Base
  ##
  # :attr: id
  # The integer key to the table.

  ##
  # :attr: widget_id
  # An id in the widgets table.

  ##
  # :attr: widget
  # A belongs_to association to Widget.
  belongs_to :widget

  ##
  # :attr: view_id
  # A foreign key that references the id field in the names table.
  # Note that the type associated with the name should be a view.
  # This is currently not checked but should be.

  ##
  # :attr: view
  # A belongs_to association to the owning View.
  belongs_to :view

  ##
  # :attr: owner_id
  # An Integer foreign key that references the id field of the users
  # table.

  ##
  # :attr: owner
  # A belongs_to association to a User that owns this element.  Note
  # that the View's owner may be different.  This is to allow someone
  # to make a clone of a View and not have to replicate all of the
  # Element in the view.
  belongs_to :owner, :class_name => "User"

  ##
  # :attr: row
  # An Integer for the row that this element will be displayed in.

  ##
  # :attr: column
  # An Integer for the column that this element will be displayed in.

  ##
  # :attr: rowspan
  # An Integer for the number of rows this element will consume

  ##
  # :attr: colspan
  # An Integer for the number of columns this element will consume.

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  validates_uniqueness_of :col, :scope => [ :view_id, :row ], :message => "[ View, row, col ] must be unique"
end
