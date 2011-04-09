# -*- coding: utf-8 -*-

# This model is the top of a Single Table Inheritance and is here so
# that names for teams, retain users (retain ids), groups,
# departments, views, and subselects are unique across all of the
# models.
class Name < ActiveRecord::Base
  ##
  # :attr: type
  # the type of node

  ##
  # :attr: name
  # the name for the node

  ##
  # :attr: owner
  # A belongs_to relation.  Only the owner can modify this entity.
  belongs_to :owner, :class_name => "User"
end
