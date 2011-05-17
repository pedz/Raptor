require 'test_helper'

class RetuserTest < ActiveSupport::TestCase
  test "database loaded" do
    assert_not_equal 0, Retuser.count
  end

  test "user belongs_to association" do
    assert_equal(@pedzan.id,
                 @pedzan_retuser.user.id)
  end
  
  # software_node not tested yet
  # hardware_node not tested yet

  test "favorite_queues has_many association" do
    assert_includes(@pedz_queue.id,
                    @pedzan_retuser.favorite_queues.map(&:queue_id))
  end

  test "containments has_many association" do
    assert_includes(@pedz_queue.id,
                    @pedzan_retuser.containments.map(&:item_id))
  end

  # retuser can not be "contained" (an item inside a container)

  test "nestings has_many association" do
    assert_includes(@pedz_queue.id,
                    @pedzan_retuser.nestings.map(&:item_id))
  end

  # retuser also can not be the item in a nesting

  test "entity has_one association" do
    assert_equal("305356", @pedzan_retuser.entity.name)
  end
end
