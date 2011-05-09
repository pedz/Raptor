require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  test "find team via entity" do
    assert_equal @ptcpk_name.id, Entity.find_by_name("ptcpk").item.id
  end

  test "find a user via entity" do
    assert_equal @pedzan.id, Entity.find_by_name("pedzan@us.ibm.com").item.id
  end

  test "find a retuser via entity" do
    assert_equal @pedzan_retuser.id, Entity.find_by_name("305356").item.id
  end

  test "name_type belongs_to association" do
    assert_equal @user_name_type.id, Entity.find_by_name("pedzan@us.ibm.com").name_type.id
  end

  test "argument_type has_one through association" do
    assert_equal @group_argument.id, Entity.find_by_name("pedzan@us.ibm.com").argument_type.id
  end
end
