require 'test_helper'

class NestingTest < ActiveSupport::TestCase
  test "database is set up" do
    assert_not_equal 0, Nesting.count
  end
  
  test "relationships are in nestings" do
    c = @ptcpk_name
    d = Nesting.find(:first, :conditions => { :container_id => c.id, :container_type => 'Name'})
    assert_not_nil d, "relationships not in nestings"
  end
  
  test "users are in nestings" do
    c = @pedzan
    d = Nesting.find(:first, :conditions => { :container_id => c.id, :container_type => 'User'})
    assert_not_nil d, "users not in nestings"
  end
  
  test "retusers are in nestings" do
    c = @pedzan_retuser
    d = Nesting.find(:first, :conditions => { :container_id => c.id, :container_type => 'Retuser'})
    assert_not_nil d, "retusers not in nestings"
  end
  
  test "items in nestings from relationships" do
    c = @ptcpk_name
    assert_includes(@ptcpk_am_name.id,
                    Nesting.find(:all,
                                 :conditions => {
                                   :container_id => c.id,
                                   :container_type => 'Name'}).map(&:item_id))
  end
  
  test "items in nestings from users" do
    c = @pedzan
    assert_includes(@pedz_queue.id,
                    Nesting.find(:all,
                                 :conditions => {
                                   :container_id => c.id,
                                   :container_type => 'User'}).map(&:item_id))
  end
  
  test "items in containmets from retusers" do
    c = @pedzan_retuser
    assert_includes(@pedz_queue.id,
                    Nesting.find(:all,
                                 :conditions => {
                                   :container_id => c.id,
                                   :container_type => 'Retuser'}).map(&:item_id))
  end
  
  test "nestings are recursive" do
    c = @ptcpk_name
    assert_includes(@amnet_queue.id,
                    Nesting.find(:all,
                                 :conditions => {
                                   :container_id => c.id,
                                   :container_type => 'Name'}).map(&:item_id))
  end
end
