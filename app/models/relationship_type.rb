# -*- coding: utf-8 -*-

# This model specifies or restrictions the types of relationships that
# can be listed in Containers.  For example, we want a Team like ptcpk
# to have a team lead, team members which will be Users and also have
# team queues that will be CachedQueues.
#
# Three examples of a Relationship would be:
#
# container_type | association_type | element_type
# Team           | team lead        | User
# Team           | team member      | User
# Team           | team queue       | CachedQueue
class RelationshipType < ActiveRecord::Base
  ##
  # :attr: container_type
  # A NameType that specifies the type of the container that can
  # participate in the relationship.
  belongs_to :container_type, :class_name => "NameType"

  ##
  # :attr: association_type
  # An AssociationType that specifies the type of association (yea.  I
  # really did just type that).
  belongs_to :association_type

  ##
  # :attr: element_type
  # A NameType that specifies the type of elements that will be contained.
  belongs_to :element_type, :class_name => "NameType"
end
