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
  # :attr: container_types
  # A has_many list of type Relationship where the specified type is
  # used as a container.
  has_many :container_types, :class_name => "Relationship", :foreign_key => :container_type_id

  ##
  # :attr: item_types
  # A has_many list of type Relationship that the specified type is
  # used as the contained item.
  has_many :item_types,   :class_name => "Relationship", :foreign_key => :item_type_id

  ##
  # :attr: names
  # A has_many list of Name records using this NameType
  has_many :names, :class_name => "Name", :foreign_key => :type, :primary_key => :name_type

  ##
  # :attr: argument_type
  # A belongs_to association to the ArgumentType for this NameType
  belongs_to :argument_type
end
