# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class ConditionsTest < ActiveSupport::TestCase
  test "db is loaded" do
    assert_not_equal 0, Condition.count
  end

  test "condition belongs_to name association for filters" do 
    assert_equal @all_name.id, @all_condition.name.id
  end

  test "condition belongs_to name association for levels" do 
    assert_equal @top_name.id, @top_condition.name.id
  end
end
