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
  # The name of the Entity

  ##
  # :attr: item
  # A polymorphic belongs_to association to the actual item
  # represented by the name.  Note that some element within the item
  # will match the name attribute
  belongs_to :item, :polymorphic => true

  ##
  # :attr: name_type
  # A has_one association to NameType for the item in the Entity
  belongs_to :name_type, :primary_key => :name, :foreign_key => :item_type

  ##
  # : attr : argument_type
  # A has_one association via the name_type association to the
  # ArgumentType for the item.
  # This (I believe) has a bug.  It should notice that :promary_key
  # for :name_type is :name but it does not and tries to do the search
  # using "name_types".id (instead of "name_types".name
  # has_many :argument_type, :through => :name_type

  # Get the ArgumentType associated with the item
  def argument_type
    name_type.argument_type
  end
end
