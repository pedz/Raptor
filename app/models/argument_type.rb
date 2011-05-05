# -*- coding: utf-8 -*-
class ArgumentType < ActiveRecord::Base
  ##
  # :attr: name
  # String for the name of the argument type.  Initially this will be
  # one of "group", "level", "filter", or "view"

  ##
  # :attr: default
  # String that is the default value for this attribute

  ##
  # :attr: name_types
  # A has_many association of NameType that can be used for this
  # ArgumentType
  has_many :name_types
end
