# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# A Relationship is a specific instance of a RelationshipType.  See
# AssociationType for how and why these models exist.  Each
# Relationship specifies a container name that contains an item as
# well as the relationship type that the two share.
class Relationship < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for this table.

  ##
  # :attr: container_name_id
  # The Integer id of a Name

  ##
  # :attr: container_name
  # A belongs_to association to Name.
  belongs_to :container_name, :class_name => "Name"

  ##
  # :attr: relationship_type_id
  # The Integer id of a RelationshipType

  ##
  # :attr: relationship_type
  # A belongs_to association to a RelationshipType
  belongs_to :relationship_type

  ##
  # :attr: item_id
  # The Integer id of the item.  The type and therefor the table is
  # specified by item_type

  ##
  # :attr: item_type
  # A String that specifies the type for the item.

  ##
  # :attr: item
  # A polymorphic has_many association of the item that is contained.
  belongs_to :item, :polymorphic => true

  ##
  # We store the base type instead of the actual time.  This is
  # suggested in the ActiveRecord::Associations::ClassMethods
  # documentation
  def item_type=(sType)
    super(sType.to_s.classify.constantize.base_class.to_s)
  end
end
