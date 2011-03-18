# -*- coding: utf-8 -*-

# = View
#
# A view is a collection of elements.  When rendered, it HTML page will be presented.
#
# ==Fields
# <em>id - integer</em>:: Key for the table
# <em>name - string</em>:: Name of the view
# <em>owner_id - integer</em>:: Owner of the view
#
class View < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :elements
  validates_uniqueness_of :name
end
