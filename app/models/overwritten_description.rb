# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class OverwrittenDescription < ActiveRecord::Base
  set_table_name "c_overwritten_description"
  set_inheritance_column 'does_not_have_one'

  belongs_to :opc_information, :primary_key => :opc_information_id, :foreign_key => :opc_information_id
  belongs_to :question_set, :primary_key => :question_set_id, :foreign_key => :question_set_id
end
