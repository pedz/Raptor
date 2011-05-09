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
    assert_includes(@team_lead_relationship_type.id,
                    @team_name_type.relationship_types.map(&:id))
  end

  test "should has_many to names" do
    assert_equal 4, @team_name_type.names.length
    assert_includes(@ptcpk_ap_name.id,
                    @team_name_type.names.map(&:id))
  end
end
