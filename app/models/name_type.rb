# -*- coding: utf-8 -*-

# A table of legal values for the type field in the Name model.
class NameType < ActiveRecord::Base
  ##
  # :attr: name_type
  # string for the type like Team.  This string needs to be an
  # ActiveRecord::Base model.

  ##
  # :attr: table_name
  # The database table that contain the items for the specified
  # name_type

  ##
  # :attr: container
  # A boolean that is true if the specified type is a container

  ##
  # :attr: containable
  # A boolean that is true if the items can be within a container.

  ##
  # A has_many list of type Relationship where the specified type is
  # used as a container.
  has_many :container_types, :class_name => "Relationship", :foreign_key => :container_type_id

  ##
  # A has_many list of type Relationship that the specified type is
  # used as the contained element.
  has_many :element_types,   :class_name => "Relationship", :foreign_key => :element_type_id
end
