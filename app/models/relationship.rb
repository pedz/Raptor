# -*- coding: utf-8 -*-

# This is a table that represents a many to many relationship.  Each
# row specifies how one particular element fits into a container that
# contains it.  The relationship_type specifies how the element is
# contained.
class Relationship < ActiveRecord::Base
  ##
  # :attr: container_name
  # The Name object for the container which will specify the specific
  # class of the container.
  belongs_to :container_name, :class_name => "Name"

  ##
  # :attr: relationship_type
  # The relationship that the container has to the element.
  belongs_to :relationship_type

  ##
  # :attr: elements
  # A polymorphic has_many relationship
  belongs_to :element_name, :polymorphic => true

  ##
  # :attr: owner
  # A belongs_to relationship to a User model
  belongs_to :owner, :class_name => "User"
end