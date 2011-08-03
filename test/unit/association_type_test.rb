# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class AssociationTypeTest < ActiveSupport::TestCase
  test "db is loaded" do
    assert_not_equal 0, AssociationType.count
  end

  test "relationship_types has_many association" do
    assert_includes(@team_member_relationship_type.id,
                    @team_member_association_type.relationship_types.map(&:id))
  end

  test "relationships has_many through association" do
    assert_includes(@ptcpk_am_team_member_pedzan_relationship.id,
                    @team_member_association_type.relationships.map(&:id))
  end
end
