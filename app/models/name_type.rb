# -*- coding: utf-8 -*-

# A table of legal values for the type field in the Name model.
class NameType < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: name
  # string for the type like Team.  This string needs to be an
  # ActiveRecord::Base model.

  ##
  # :attr: base_type
  # The base_type for the name.  This is set via a call back during
  # the save process.

  ##
  # :attr: table_name
  # The database table that contain the items for the specified
  # name.  This is set via a call back during the save process.

  ##
  # :attr: argument_type_id
  # The Integer id of an ArgumentType

  ##
  # :attr: argument_type
  # A belongs_to association specifying the ArgumentType that this
  # NameType can be used for.
  belongs_to :argument_type

  ##
  # :attr: container
  # A boolean that is true if the specified type is a container

  ##
  # :attr: containable
  # A boolean that is true if the items can be within a container.

  ##
  # :attr: relationship_types
  # A has_many association to RelationshipType that is the list that
  # uses this NameType as its container_type
  has_many :relationship_types, :foreign_key => :container_type_id

  ##
  # :attr: names
  # A has_many list of Name records using this NameType
  has_many :names, :class_name => "Name", :foreign_key => :type, :primary_key => :name

  ##
  # :attr: entities
  # A has_many list of Entities using this NameType
  has_many :entities

  before_save :set_base_type

  # Automagically set base_type and table_name.  The stored PostgreSQL
  # functions need these to implement some check constraints
  def set_base_type
    self.base_type = self.name.to_s.classify.constantize.base_class.to_s
    self.table_name = self.name.to_s.classify.constantize.base_class.table_name.to_s
  end
end
