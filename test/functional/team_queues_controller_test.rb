require 'test_helper'

class TeamQueuesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:team_queues)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create team_queue" do
    assert_difference('TeamQueue.count') do
      post :create, :team_queue => { }
    end

    assert_redirected_to team_queue_path(assigns(:team_queue))
  end

  test "should show team_queue" do
    get :show, :id => team_queues(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => team_queues(:one).to_param
    assert_response :success
  end

  test "should update team_queue" do
    put :update, :id => team_queues(:one).to_param, :team_queue => { }
    assert_redirected_to team_queue_path(assigns(:team_queue))
  end

  test "should destroy team_queue" do
    assert_difference('TeamQueue.count', -1) do
      delete :destroy, :id => team_queues(:one).to_param
    end

    assert_redirected_to team_queues_path
  end
end
