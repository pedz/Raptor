# -*- coding: utf-8 -*-

# This model is the top of a Single Table Inheritance and is here so
# that names for teams, retain users (retain ids), groups,
# departments, views, and subselects are unique across all of the
# models.  See NameType for how this is specified.  Also see Entity
# for the top level database relation (which is actually a view) that
# Name is a part of.
class Name < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer key to the table.

  ##
  # :attr: type
  # A String for the type of node

  ##
  # :attr: name
  # A String the name for the node

  ##
  # :attr: owner_id
  # The Integer id for a User

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: name_type
  # A belongs_to association to NameType
  belongs_to :name_type, :primary_key => :name, :foreign_key => :type

  ##
  # :attr: owner
  # A belongs_to association to the User that owns this name.  Only
  # the owner will be allowed to delete this name as well as modify
  # associations using this name.
  belongs_to :owner, :class_name => "User"

  ##
  # :attr: container_names
  # A has_many association to Relationship specifying this Name as its
  # Relationship#container_name.
  has_many(:container_names,
           :class_name => "Relationship",
           :primary_key => :id,
           :foreign_key => :container_name_id)

  ##
  # :attr: containments
  # A has_many association to Containment that specifies this Name as
  # the container.
  has_many :containments, :as => :container

  ##
  # :attr: containment_items
  # A has_many association to Containment that specifies this Name as
  # the item being contained.
  has_many :containment_items, :class_name => "Containment", :as => :item

  ##
  # :attr: nestings
  # A has_many association to Nesting that specifies this Name as the
  # container.
  has_many :nestings, :as => :container

  ##
  # :attr: nesting_items
  # A has_many association to Nesting that specifies this Name as
  # the item being contained.
  has_many :nesting_items, :class_name => "Nesting", :as => :item

  ##
  # :attr: entity
  # A has_one association to the associated Entity.
  has_one :entity, :class_name => "Entity", :as => :item

  validates_uniqueness_of :name

  # Returns the name of the item.  Any class used as an item in a
  # Relationship must define this method (so the UI can display
  # something nice).
  def item_name
    name
  end
end
