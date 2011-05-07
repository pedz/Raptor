# -*- coding: utf-8 -*-

# A Nesting is the transitive closure of a Container (over the
# containers view).
class Nesting < ActiveRecord::Base
  ##
  # :attr: container
  # Object A polymorphic belongs_to which may result in a Name, User,
  # Retuser, etc.
  belongs_to :container, :polymorphic => true

  ##
  # :attr: item
  # Object A polymorphic belongs_to which may result in many different
  # types including Name, User, Cached::Queue, etc.
  belongs_to :item,      :polymorphic => true

  ##
  # :attr: level
  # Integer The number of nesting levels between the container and the item.
end
