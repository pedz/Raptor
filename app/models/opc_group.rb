# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class OpcGroup < ActiveRecord::Base
  set_table_name "c_opc_group"

  has_many :components, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
  has_many :target_components, :foreign_key => :opc_group_id, :primary_key => :opc_group_id
end
