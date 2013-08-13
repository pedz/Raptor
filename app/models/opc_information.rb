# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class OpcInformation < ActiveRecord::Base
  set_table_name "c_opc_information"
  set_inheritance_column 'does_not_have_one'

  has_one :answer, :primary_key => :opc_information_id, :foreign_key => :answer_id
  has_many :overwritten_descriptions, :primary_key => :opc_information_id, :foreign_key => :opc_information_id
  has_one :question, :primary_key => :opc_information_id, :foreign_key => :question_id
  belongs_to(:parent,
             :class_name => 'OpcInformation',
             :foreign_key => :parent_id,
             :primary_key => :opc_information_id)
  has_many(:children,
           :class_name => 'OpcInformation',
           :foreign_key => :parent_id,
           :primary_key => :opc_information_id)
  has_many(:opc_dependencies, :primary_key => :opc_information_id, :foreign_key => :dependency_opc_information_id)
end
