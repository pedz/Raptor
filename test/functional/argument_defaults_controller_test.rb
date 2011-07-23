require 'test_helper'

class ArgumentDefaultsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:argument_defaults)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create argument_default" do
    assert_difference('ArgumentDefault.count') do
      post :create, :argument_default => { }
    end

    assert_redirected_to argument_default_path(assigns(:argument_default))
  end

  test "should show argument_default" do
    get :show, :id => argument_defaults(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => argument_defaults(:one).to_param
    assert_response :success
  end

  test "should update argument_default" do
    put :update, :id => argument_defaults(:one).to_param, :argument_default => { }
    assert_redirected_to argument_default_path(assigns(:argument_default))
  end

  test "should destroy argument_default" do
    assert_difference('ArgumentDefault.count', -1) do
      delete :destroy, :id => argument_defaults(:one).to_param
    end

    assert_redirected_to argument_defaults_path
  end
end
