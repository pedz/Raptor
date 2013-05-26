# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class IgnoreBaseItem < ActiveRecord::Base
  set_table_name "c_ignore_base_item"
  belongs_to :question_set, :foreign_key => :question_set_id, :primary_key => :question_set_id
  has_one :opc_information, :foreign_key => :opc_information_id, :primary_key => :opc_information_id
end
