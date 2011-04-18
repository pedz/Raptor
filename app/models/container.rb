# -*- coding: utf-8 -*-

# This is a table that represents a many to many relationship.  Each
# row specifies how one particular element fits into a container that
# contains it.  The relationship specifies how the element is
# contained.
class Container < ActiveRecord::Base
  ##
  # :attr: container_name
  # The Name object for the container which will specify the specific
  # class of the container.
  belongs_to :container_name, :class_name => "Name"

  ##
  # :attr: relationship
  # The relationship that the container has to the element.
  belongs_to :relationship

  ##
  # :attr: elements
  # A polymorphic has_many relationship
  belongs_to :element_name, :polymorphic => true

  ##
  # :attr: owner
  # A belongs_to relationship to a User model
  belongs_to :owner, :class_name => "User"
end
