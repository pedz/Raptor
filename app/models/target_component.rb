# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class TargetComponent < ActiveRecord::Base
  set_table_name "c_target_component"
  set_inheritance_column 'does_not_have_one'

  has_one :component, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
  has_one :opc_group, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
end
