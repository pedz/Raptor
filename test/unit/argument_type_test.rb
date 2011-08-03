# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class ArgumentTypeTest < ActiveSupport::TestCase
  test "database is set up" do
    assert_equal 4, ArgumentType.count
  end

  test "should has_many name_types" do
    assert_includes @retuser_name_type.id, @group_argument.name_types.map(&:id)
  end

  test "argument_type has_many entities" do
    assert_includes(@ptcpk_am_name.name,
                    @group_argument.entities.map(&:name))
  end
end
