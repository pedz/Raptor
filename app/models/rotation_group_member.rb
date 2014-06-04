# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class RotationGroupMember < ActiveRecord::Base
  validates_uniqueness_of :name, :scope => :rotation_group_id
  validates_uniqueness_of :user_id, :scope => :rotation_group_id
  validates_presence_of :name, :user_id
  
  ##
  # :attr: rotation_group
  # A belongs_to association to the owning RotationGroup
  belongs_to :rotation_group
  
  ##
  # :attr: user
  # A belongs_to association to the user
  belongs_to :user

  ##
  # :attr: is_active
  # A named_scope for active is true
  named_scope :is_active, :conditions => { :active => true }

  def ldap_id
    user.ldap_id
  end

  def queue_name
    user.queue.queue_name
  end
end
