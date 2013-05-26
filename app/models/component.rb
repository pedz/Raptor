# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class Component < ActiveRecord::Base
  set_table_name "c_component"

  has_many :component_versions, :foreign_key => :component_id, :primary_key => :component_id
  belongs_to :question_set, :foreign_key => :question_set_id, :primary_key => :question_set_id
  belongs_to :opc_group, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
  has_many :target_components, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
end
