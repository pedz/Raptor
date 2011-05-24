# -*- coding: utf-8 -*-

# For a given container (which is an Entity) there will be a list of
# items that it contains.  The actual implementation is a view.
class Containment < ActiveRecord::Base
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
  # Integer Always equal to 1
end