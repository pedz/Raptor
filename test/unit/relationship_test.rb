# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  test "db is loaded" do
    assert_not_equal 0, Relationship.count
  end

  test "container_name belongs_to association" do
    assert_equal @ptcpk_name.id, @ptcpk_contains_ptcpk_am_relationship.container_name.id
  end

  test "relationship_type belongs_to association" do
    assert_equal(@team_team_relationship_type.id,
                 @ptcpk_contains_ptcpk_am_relationship.relationship_type.id)
  end

  test "item belongs_to polymorphic association" do
    assert_equal @ptcpk_am_name.id, @ptcpk_contains_ptcpk_am_relationship.item.id
  end

  test "Creating a loop fails" do
    # Assumes that ptcpk contains ptcpk-am.  Attempts to create a
    # relation where ptcpk-am contains ptcpk
    r = Relationship.new
    r.container_name = @ptcpk_am_name
    r.relationship_type = @team_team_relationship_type
    r.item = @ptcpk_name
    assert_raises(ActiveRecord::StatementInvalid) {
      r.save
    }
  end
end
