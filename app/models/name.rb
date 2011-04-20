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

  ##
  # :attr: name_type
  # The type of the name must be a name_type in the name_types table.
  # This does not work... not sure exactly why but its not critical to me right now.
  # belongs_to :name_type, :class_name => "NameType", :primary_key => "type", :foreign_key => "name_type"

  validates_uniqueness_of :name
end
