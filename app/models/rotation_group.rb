# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class RotationGroup < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name

  ##
  # :attr: rotation_group_members
  # A has_many relation to the list of type RotationGroupMember for this RotationGroup
  has_many :rotation_group_members
end
