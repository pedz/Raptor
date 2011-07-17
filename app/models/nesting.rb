# -*- coding: utf-8 -*-

# A Nesting is the transitive closure of a Container (over the
# containers view).  Thus if ptcpk contains ptcpk-am and ptcpk-am
# contains Joe and Bob, then there will be a Nesting for ptcpk
# containing Joe and Bob.
#
# A Nesting is not used directly very often but is used from other
# models such as Name.nestings and Name.nesting_items
class Nesting < ActiveRecord::Base
  ##
  # :attr:  container_id
  # The id of the container

  ##
  # :attr: container_type
  # The type of the container

  ##
  # :attr: item_id
  # The id of the item

  ##
  # :attr: item_type
  # The type of the item

  ##
  # :attr: level
  # Integer The number of nesting levels between the container and the item.

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
end
