# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class Component < ActiveRecord::Base
  set_table_name "c_component"

  belongs_to :opc_group, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
  belongs_to :question_set, :foreign_key => :question_set_id, :primary_key => :question_set_id

  # Not sure how to use this.  Ignore for now
  has_many :component_versions, :foreign_key => :component_id, :primary_key => :component_id

  # Logically I believe this is via opc_group
  has_many :target_components, :foreign_key => :opc_group_id, :primary_key => :opc_group_id

  # Logically I believe this is via question_set
  has_many :overwritten_descriptions, :foreign_key => :question_set_id, :primary_key => :question_set_id
  has_many :ignore_base_items, :primary_key => :question_set_id, :primary_key => :question_set_id
end
