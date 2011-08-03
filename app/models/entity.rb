# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
#
# An Entity is a very generic term which may be any thing given in the
# "calls" or "queues" list of arguments.  Entities is a view that is
# the UNION of Name, User, Retuser, and Cached::Queue models which are
# then joined to NameType table and the ArgumentType models.
#
# Given a name of an Entity, it can be looked up and the result will
# contain a polymorphic item which will be the actual item.  This item
# can later be used to find all of the elements it contains or other
# attributes.
class Entity < ActiveRecord::Base
  ##
  # :attr: name
  # The name of the Entity

  ##
  # :attr: real_type
  # The actual type of the Entity.  We can't call this "type" or
  # ActiveRecord thinks it is to be used for an STI which we don't
  # want in this case.  For subclasses of Name, this will be the
  # subclass such as Team

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
  # The same as NameType#base_type.  For subclasses of Name, this will
  # be Name.

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
  # :attr: updated_at
  # The updated_at field from the record that name came from -- thus
  # it is when the name record was last updated.

  ##
  # :attr: item
  # A polymorphic belongs_to association to the actual item
  # represented by the name.  Note that some element within the item
  # will match the name attribute
  belongs_to :item, :polymorphic => true

  ##
  # A has_many assocation with Containment via the item
  def containments
    item.containments
  end

  ##
  # A has_many assocation with Nesting via the item
  def nestings
    item.nestings
  end

  def to_json(options = nil)
    attributes.to_json(options)
  end
end
