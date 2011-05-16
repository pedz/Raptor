# -*- coding: utf-8 -*-

# The "call" and "queue" URLs have arguments in the form of paths.
# ArgumentType specifies for a given name, the position it can be in
# the path (or for a given position, the name of the argument).  It
# also specifies the default is no such argument type is given.
class ArgumentType < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: name
  # A String for the name of the argument type.  Initially this will
  # be one of "group", "level", "filter", or "view"

  ##
  # :attr: default
  # A String that specifies the default value for this argument.

  ##
  # :attr: position
  # An Integer that specifies the position this arguement will be in.

  ##
  # :attr: name_types
  # A has_many association of NameType that use this ArgumentType
  has_many :name_types

  ##
  # :attr: entities
  # A has_many association of Entity that use this ArgumentType
  has_many :entities
end
