# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class ContainmentTest < ActiveSupport::TestCase
  test "database is set up" do
    assert_not_equal 0, Containment.count
  end

  test "relationships are in containments" do
    c = @ptcpk_name
    d = Containment.find(:first, :conditions => { :container_id => c.id, :container_type => 'Name'})
    assert_not_nil d, "relationships not in containments"
  end

  test "users are in containments" do
    c = @pedzan
    d = Containment.find(:first, :conditions => { :container_id => c.id, :container_type => 'User'})
    assert_not_nil d, "users not in containments"
  end

  test "retusers are in containments" do
    c = @pedzan_retuser
    d = Containment.find(:first, :conditions => { :container_id => c.id, :container_type => 'Retuser'})
    assert_not_nil d, "retusers not in containments"
  end

  test "items in containments from relationships" do
    c = @ptcpk_name
    assert_includes(@ptcpk_am_name.id,
                    Containment.find(:all,
                                     :conditions => {
                                       :container_id => c.id,
                                       :container_type => 'Name'}).map(&:item_id))
  end

  test "items in containments from users" do
    c = @pedzan
    assert_includes(@pedz_queue.id,
                    Containment.find(:all,
                                     :conditions => {
                                       :container_id => c.id,
                                       :container_type => 'User'}).map(&:item_id))
  end

  test "items in containmets from retusers" do
    c = @pedzan_retuser
    assert_includes(@pedz_queue.id,
                    Containment.find(:all,
                                      :conditions => {
                                        :container_id => c.id,
                                        :container_type => 'Retuser'}).map(&:item_id))
  end

  test "containments are not recursive" do
    c = @ptcpk_name
    assert_does_not_include(@amnet_queue.id,
                            Containment.find(:all,
                                             :conditions => {
                                               :container_id => c.id,
                                               :container_type => 'Name'}).map(&:item_id))
  end
end
