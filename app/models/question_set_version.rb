# -*- coding: utf-8 -*-
#
# Copyright 2007-2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

# This is a model picked up to do OPC
class QuestionSetVersion < ActiveRecord::Base
  set_table_name "c_question_set_version"

  belongs_to :question_set, :foreign_key => :question_set_id, :primary_key => :question_set_id
  belongs_to(:base_version,
             :class_name => 'QuestionSetVersion',
             :foreign_key => :base_version_id,
             :primary_key => :question_set_version_id)
  belongs_to(:root_question,
             :class_name => 'Question',
             :foreign_key => :root_question_id,
             :primary_key => :question_id)
end
