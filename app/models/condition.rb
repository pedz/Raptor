# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# The model for an SQL Condition to be used with the Filter or Level
# models.
class Condition < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for the table.

  ##
  # :attr: name_id
  # Integer id to a Name

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
  # A belongs_to association to a Name
  belongs_to :name, :foreign_key => :name_id

  ##
  # :attr: sql
  # A String that is the SQL for the condition
end
