# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "database loaded" do
    assert_not_equal 0, User.count
  end

  test "retuser has_many assocation" do
    assert_includes(@pedzan_retuser.id,
                    @pedzan.retusers.map(&:id))
  end

  test "current_retain_id belongs_to association" do
    # We can not set this up in the fixture because of a circular
    # dependency so we test to see if we can assign to it and hope
    # that is good enough.
    @pedzan.current_retain_id = @pedzan_retuser
    assert_equal true, @pedzan.save

    # Sanity check to make sure it happened.  Not sure if this is
    # really real or not.
    assert_equal @pedzan_retuser.id, @pedzan.current_retain_id.id
  end

  test "faroite_queues has_many association" do
    # We hvae to set the current_retain_id in order to use
    # favorite_queues.
    @pedzan.current_retain_id = @pedzan_retuser
    assert_includes(@pedzan_favorite_amnet.id,
                    @pedzan.favorite_queues.map(&:id))
  end

  test "relatoinships has_many association" do
    assert_includes(@ptcpk_am_team_member_pedzan_relationship.id,
                    @pedzan.relationships.map(&:id))
  end

  test "containments has_many assocation" do
    assert_includes(@pedz_queue.id,
                    @pedzan.containments.map(&:item_id))
  end

  test "containment_items has_many association" do
    assert_includes(@ptcpk_am_name.id,
                    @pedzan.containment_items.map(&:container_id))
  end

  test "nestings has_many assocation" do
    assert_includes(@pedz_queue.id,
                    @pedzan.nestings.map(&:item_id))
  end

  test "nesting_items has_many association" do
    assert_includes(@ptcpk_am_name.id,
                    @pedzan.nesting_items.map(&:container_id))
  end

  test "entity has_one association" do
    assert_equal("pedzan@us.ibm.com", @pedzan.entity.name)
  end
end
