# -*- coding: utf-8 -*-
#
# An Entity is a very generic term which may be any thing given in the
# "calls" or "queues" list of arguments.  Entities is a view that is
# the UNION of Relationship, User, and Retuser tables.  It is then
# joined to the name_types table and the argument_types table.
#
# Given a name of an Entity, it can be looked up and the result will
# contain a polymorphic item which will be the actual item.  This item
# can later be used to find all of the elements it contains using the
# Container or Nesting
class Entity < ActiveRecord::Base
  ##
  # :attr: name
  # The name of the Entity

  ##
  # :attr: real_type
  # The actual type of the Entity.  We can't call this "type" or
  # ActiveRecord thinks it is to be used for an STI which we don't
  # want in this case.

  ##
  # :attr: item_id
  # The id of the item

  ##
  # :attr: item_type
  # The type for the item which is really the base_class of the item
  # since that is what the polymorphic associations want

  ##
  # :attr: name_type_id
  # The same as NameType#id

  ##
  # :attr: name_type
  # A belongs_to association to NameType.  This is here just for
  # completeness since all the info is already in the Entity.
  belongs_to :name_type

  ##
  # :attr: base_type
  # The same as NameType#base_type

  ##
  # :attr: table_name
  # The same as NameType#table_name

  ##
  # :attr: container
  # The same as NameType#container

  ##
  # :attr: containable
  # The same as NameType#containable

  ##
  # :attr: argument_type_id
  # The same as ArgumentType#id

  ##
  # :attr: argument_type
  # A belongs_to association to ArgumentType.  This is here for
  # completeness since all the data is already in the Entity
  belongs_to :argument_type

  ##
  # :attr: argument_type
  # The same as ArgumentType#name

  ##
  # :attr: default
  # The same as ArgumentType#defect

  ##
  # :attr: position
  # The same as ArgumentType#position

  ##
  # :attr: item
  # A polymorphic belongs_to association to the actual item
  # represented by the name.  Note that some element within the item
  # will match the name attribute
  belongs_to :item, :polymorphic => true
end
