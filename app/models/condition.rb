# -*- coding: utf-8 -*-

# The model for an SQL Condition to be used with the Filter or Level
# models.
class Condition < ActiveRecord::Base
  ##
  # :attr: name_id
  # Integer id to a Name

  ##
  # :attr: name
  # A belongs_to association to a Name
  belongs_to :name, :foreign_key => :name_id

  ##
  # :attr: sql
  # A String that is the SQL for the condition
end