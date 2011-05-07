require 'test_helper'

class ArgumentTypeTest < ActiveSupport::TestCase
  test "database is set up" do
    assert_equal 4, ArgumentType.count
  end

  test "should has_many name_types" do
    assert_equal 6, @group_argument.name_types.length
  end
end
