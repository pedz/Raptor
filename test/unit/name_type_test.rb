require 'test_helper'

class NameTypeTest < ActiveSupport::TestCase
  test "database is set up" do
    assert_equal 9, NameType.count
  end

  test "should belong_to argument_type" do
    assert_equal @group_argument.id, @dept_name_type.argument_type.id
  end

  test "should has_many to relationship_types" do
    assert_equal 4, @team_name_type.relationship_types.length
  end

  test "should has_many to names" do
    assert_equal 4, @team_name_type.names.length
  end
end
