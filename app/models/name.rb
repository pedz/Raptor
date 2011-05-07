# -*- coding: utf-8 -*-

# This model is the top of a Single Table Inheritance and is here so
# that names for teams, retain users (retain ids), groups,
# departments, views, and subselects are unique across all of the
# models.
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
  # :attr: name_type
  # A belongs_to association to NameType
  belongs_to :name_type, :primary_key => :name_type, :foreign_key => :type

  ##
  # :attr: owner
  # A belongs_to association to the User that owns this name.  Only
  # the owner will be allowed to delete this name as well as modify
  # associations using this name.
  belongs_to :owner, :class_name => "User"

  ##
  # :attr: container_names
  # A has_many association to Relationship specifying this Name as its
  # Relationship#container_name
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
  # the container.
  has_many :containment_items, :class_name => "Containment", :as => :item

  ##
  # :attr: nestings
  # A has_many association to Nesting that specifies this Name as the
  # container.
  has_many :nestings, :as => :container

  ##
  # :attr: nesting_items
  # A has_many association to Nesting that specifies this Name as
  # the container.
  has_many :nesting_items, :class_name => "Nesting", :as => :item

  ##
  # :attr: entity
  # A has_one association to an Entity.
  has_one :entity, :class_name => "Entity", :as => :item

  validates_uniqueness_of :name

  # # Not a true association but returns the NameType associated with this Name
  # def name_type
  #   NameType.find_by_name_type(self.becomes(Name).type)
  # end

  # A common method by that any class used as an item in a
  # Relationship to return the "name" associated with the item
  def item_name
    name
  end
end
