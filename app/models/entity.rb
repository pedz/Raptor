# -*- coding: utf-8 -*-
#
# An Entity is a very generic term which may be any thing given in the
# "calls" or "queues" list of arguments.  Entities is a view that is
# the UNION of Relationship, User, and Retuser tables.  Given a name
# of an Entity, it can be looked up and the result will contain a
# polymorphic item which will be the actual item.  This item can later
# be used to find all of the elements it contains using the Container
# or Nesting
class Entity < ActiveRecord::Base
  ##
  # :attr: name
  # String The name of the Entity

  ##
  # :attr: item
  # Object A polymorphic belongs_to association to the actual item
  # represented by the name.  Note that some element within the item
  # will match the name attribute
  belongs_to :item, :polymorphic => true

  has_one :name_type, :foreign_key => :item_type, :primary_key => :name_type
end
