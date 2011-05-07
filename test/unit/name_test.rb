require 'test_helper'

class NameTest < ActiveSupport::TestCase
  test "database loaded" do
    assert_not_equal 0, Name.count
  end

  test "owner belongs_to association" do
    assert_equal @pedzan.id, @ptcpk_name.owner.id
  end

  test "container_names has_many association" do
    assert_equal 1, @ptcpk_name.container_names.length
  end

  test "container_names has_many association 2" do
    assert_equal 3, @ptcpk_am_name.container_names.length
  end

  test "containments has_many association" do
    assert_equal 1, @ptcpk_name.containments.length
  end

  test "containments has_many association 3" do
    assert_equal 3, @ptcpk_am_name.containments.length
  end
end
