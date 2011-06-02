# -*- coding: utf-8 -*-

# A widget is a chunk of javascript code that can be added as an
# element into a view.  When the view is rendered, the javascript code
# is called to produce the text as well as the style.  Details of this
# interface will be worked out.
class Widget < ActiveRecord::Base
  ##
  # :attr: id
  # Integer key for the table

  ##
  # :attr: name
  # String name of the widget

  ##
  # :attr: code
  # String javascript code snippet that implements the Widget.

  ##
  # :attr: owner
  # belongs_to association to a User that owns the widget
  belongs_to :owner, :class_name => "User"

  validates_uniqueness_of :name
end
