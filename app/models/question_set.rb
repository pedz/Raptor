# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class QuestionSet < ActiveRecord::Base
  set_table_name "c_question_set"
  set_inheritance_column 'does_not_have_one'

  has_many :components, :foreign_key => :question_set_id, :primary_key => :question_set_id
  has_many :question_set_versions, :foreign_key => :question_set_id, :primary_key => :question_set_id
  has_many :ignore_base_items, :primary_key => :question_set_id, :primary_key => :question_set_id
  has_many :overwritten_descriptions, :primary_key => :question_set_id, :foreign_key => :question_set_id
end
