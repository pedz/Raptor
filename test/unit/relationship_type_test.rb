# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class RelationshipTypeTest < ActiveSupport::TestCase
  test "db is loaded" do
    assert_not_equal 0, RelationshipType.count
  end

  test "container_type belongs_to association" do
    assert_equal @team_name_type.id, @team_lead_relationship_type.container_type.id
  end

  test "association_type belongs_to association" do
    assert_equal(@team_lead_association_type.id,
                 @team_lead_relationship_type.association_type.id)
  end

  test "item_type belongs_to association" do
    assert_equal(@user_name_type.id,
                 @team_member_relationship_type.item_type.id)
  end

  test "relationships has_many association" do
    assert_includes(@ptcpk_contains_ptcpk_am_relationship.id,
                    @team_team_relationship_type.relationships.map(&:id))
  end
end
