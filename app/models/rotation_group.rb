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

  ##
  # :attr: rotation_types
  # A has_many relation to the list of type RotationGroupMember for this RotationGroup
  has_many :rotation_types

  ##
  # :attr: queue
  # A belogns_to association to a Cached::Queue that the entry refers
  # to.
  belongs_to :queue, :class_name => "Cached::Queue"

  ##
  # :attr: rotation_assignments
  # A has_many association to the RotationAssignments made for this RotationGroup
  has_many :rotation_assignments

  def sorted_active_group_members
    rotation_group_members.all(:conditions => {:active => true }, :order => :name)
  end

  def sorted_assignments
    rotation_assignments.all(:order => :created_at)
  end
end
