# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# A mapping specifies the SQL to use to get the list of subjects (such
# as calls) given a list of sources (such as queues).  Subjects refer
# to a Name whose type is 'Subject'.  Sources refer to a NameType
# whose base_type is not equal to 'Name'  A NameType whose base_type
# is equal to 'Name' is just a container of one type or another.
class Mapping < ActiveRecord::Base
  ##
  # :attr: id
  # The Integer primary key for this table.

  ##
  # :attr: subject_id
  # The Integer id of a Name whose type must be 'Subject'

  ##
  # :attr: subject
  # A belongs_to association to Name
  belongs_to :subject, :class_name => "Name"

  ##
  # :attr: source_id
  # The Integer id of a NameType whose base_type must not be 'Name'

  ##
  # :attr: source
  # A belongs_to association to NameType
  belongs_to :source, :class_name => "NameType"

  ##
  # :attr: sql
  # SQL phrase to search the database given a list of id of the source
  # type to produce the appropriate list of subjects
end
