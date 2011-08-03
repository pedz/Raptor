# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class ArgumentDefaultTest < ActiveSupport::TestCase
  test "name belongs_to association" do
    assert_equal "ptcpk", @argument_default_one.name.name
  end

  test "argument_type belongs_to association" do
    assert_equal "view", @argument_default_one.argument_type.name
  end
end
