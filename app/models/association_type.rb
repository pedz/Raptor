# -*- coding: utf-8 -*-

# This model specifies the kinds of RelationshipTypes.  For example,
# "team lead", "team queue", "contains", etc.
class AssociationType < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: association_type
  # A String for the association type.
  validates_uniqueness_of :association_type

  ##
  # :attr: relationship_types
  # A has_many of RelationshipType that use this AssociationType
  has_many :relationship_types

  ##
  # :attr: relationships
  # A has_many of Relationship that use (via RelationshipType) this
  # AssociationType.
  has_many :relationships, :through => :relationship_types
end
