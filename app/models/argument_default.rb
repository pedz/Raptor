# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This model allows each subject type to define its sequence of
# default arguments.  There will be entries for argument poistion 0
# even though it will be the subject itself.
class ArgumentDefault < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.
  
  ##
  # :attr: name_id
  # The id from the names table that this default is associtated with.

  ##
  # :attr: argument_position
  # Which argument position this default goes with

  ##
  # :attr: default
  # The specified default

  ##
  # :attr: created_at
  # Rails normal created_at timestamp that is when the db record was
  # created.

  ##
  # :attr: updated_at
  # Rails normal updated_at timestamp.  Each time the db record is
  # saved, this gets updated.

  ##
  # :attr: name
  # A belongs_to association to the Name that this default is
  # associated with.
  belongs_to :name

  ##
  # :attr: argument_type
  # A belongs_to association to the ArgumentType connected with the
  # argument_position.
  belongs_to :argument_type, :class_name => "ArgumentType", :foreign_key => :argument_position, :primary_key => :position
end
