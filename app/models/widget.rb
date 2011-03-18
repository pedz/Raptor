# -*- coding: utf-8 -*-

# = Widget
#
# A widget is a chunk of javascript code that can be added as an
# element into a view.  When the view is rendered, the javascript code
# is called to produce the text as well as the style.  Details of this
# interface will be worked out.
#
# ==Fields
# <em>id - integer</em>:: Key for the table
# <em>name - string</em>:: Name of the widget
# <em>owner_id - integer</em>:: Owner of the widget
# <em>code - text</em>:: The javascript code
#
class Widget < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  validates_uniqueness_of :name
end
