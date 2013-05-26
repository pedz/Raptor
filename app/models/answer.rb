# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class Answer < ActiveRecord::Base
  set_table_name "c_answer"

  belongs_to :opc_information, :primary_key => :opc_information_id, :foreign_key => :answer_id
end
