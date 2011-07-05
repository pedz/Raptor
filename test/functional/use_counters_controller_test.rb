require 'test_helper'

class UseCountersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:use_counters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create use_counter" do
    assert_difference('UseCounter.count') do
      post :create, :use_counter => { }
    end

    assert_redirected_to use_counter_path(assigns(:use_counter))
  end

  test "should show use_counter" do
    get :show, :id => use_counters(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => use_counters(:one).to_param
    assert_response :success
  end

  test "should update use_counter" do
    put :update, :id => use_counters(:one).to_param, :use_counter => { }
    assert_redirected_to use_counter_path(assigns(:use_counter))
  end

  test "should destroy use_counter" do
    assert_difference('UseCounter.count', -1) do
      delete :destroy, :id => use_counters(:one).to_param
    end

    assert_redirected_to use_counters_path
  end
end
