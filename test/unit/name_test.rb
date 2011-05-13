require 'test_helper'

class NameTest < ActiveSupport::TestCase
  test "database loaded" do
    assert_not_equal 0, Name.count
  end

  test "name_type belongs_to association" do
    assert_equal @filter_name_type.id, @all_name.name_type.id
  end

  test "owner belongs_to association" do
    assert_equal @pedzan.id, @ptcpk_name.owner.id
  end

  test "container_names has_many association" do
    assert_equal 1, @ptcpk_name.container_names.length
    assert_includes(@ptcpk_contains_ptcpk_am_relationship.id,
                    @ptcpk_name.container_names.map(&:id))
  end

  test "container_names has_many association 2" do
    assert_equal 3, @ptcpk_am_name.container_names.length
    assert_includes(@ptcpk_am_team_lead_relationship.id,
                    @ptcpk_am_name.container_names.map(&:id))
  end

  test "containments has_many association" do
    assert_equal 1, @ptcpk_name.containments.length
    assert_includes(@ptcpk_am_name.id,
                    @ptcpk_name.containments.map(&:item_id))
  end

  test "containments has_many association 2" do
    assert_equal 3, @ptcpk_am_name.containments.length
    assert_includes(@pedzan.id,
                    @ptcpk_am_name.containments.map(&:item_id))
  end

  test "nestings has_many association" do
    assert_equal 6, @ptcpk_name.nestings.length
    assert_includes(@ptcpk_am_name.id,
                    @ptcpk_name.nestings.map(&:item_id))
  end

  test "nestings has_many association 2" do
    assert_equal 5, @ptcpk_am_name.nestings.length
    assert_includes(@pedzan.id,
                    @ptcpk_am_name.nestings.map(&:item_id))
  end

  test "entity has_one association" do
    assert_equal "ptcpk", @ptcpk_name.entity.name
  end
end
