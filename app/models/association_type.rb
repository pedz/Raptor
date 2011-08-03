# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This model specifies the kinds associations that can be created.  It
# simply limits the choices a user can make when defining a
# RelationshipType which then limit the user when defining a
# Relationship.  An example of an association type is "team lead".  An
# example of a relationship type is the tuple < Team, team lead, User
# > which denotes that a User can be the team lead for a Team.  A
# Relationship is a specific instance of that such as Joe is the team
# lead of the SWAT team.  The objective is to prevent creating
# relationships that make no sense such as making a team the manager
# of a department.
class AssociationType < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: association_type
  # A String for the association type.
  validates_uniqueness_of :association_type

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

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
