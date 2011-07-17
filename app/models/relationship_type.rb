# -*- coding: utf-8 -*-

# This model specifies or restrictions the types of relationships that
# can be listed in a Relationship.  For example, we want a Team like ptcpk
# to have a team lead, team members which will be Users and also have
# team queues that will be Cached::Queues.
#
# Three examples of a RelationshipType would be:
#
# container_type | association_type | item_type
# Team           | team lead        | User
# Team           | team member      | User
# Team           | team queue       | CachedQueue
class RelationshipType < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: container_type_id
  # The Integer id of a NameType that specifies the type of the
  # container.

  ##
  # :attr: container_type
  # A NameType that specifies the type of the container that can
  # participate in the relationship.
  belongs_to :container_type, :class_name => "NameType"

  ##
  # :attr: association_type_id
  # The Integer id for the AssociationType that this RelationshipType
  # uses.
  
  ##
  # :attr: association_type
  # An AssociationType that specifies the type of association (yea.  I
  # really did just type that).
  belongs_to :association_type

  ##
  # :attr: item_type_id
  # The Integer id for the NameType that this RelationshipType
  # specifies for the item that it can contain.

  ##
  # :attr: item_type
  # A NameType that specifies the type of items that will be contained.
  belongs_to :item_type, :class_name => "NameType"

  ##
  # :attr: relationships
  # A has_many association to Relationship that use this
  # RelationshipType.
  has_many :relationships

  def to_option
    "<#{container_type.name},#{association_type.association_type},#{item_type.name}>"
  end
end
