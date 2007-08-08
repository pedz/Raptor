require File.dirname(__FILE__) + '/../test_helper'
require 'retain_users_controller'

# Re-raise errors caught by the controller.
class RetainUsersController; def rescue_action(e) raise e end; end

class RetainUsersControllerTest < Test::Unit::TestCase
  fixtures :retain_users

  def setup
    @controller = RetainUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:retain_users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_retain_user
    assert_difference('RetainUser.count') do
      post :create, :retain_user => { }
    end

    assert_redirected_to retain_user_path(assigns(:retain_user))
  end

  def test_should_show_retain_user
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_retain_user
    put :update, :id => 1, :retain_user => { }
    assert_redirected_to retain_user_path(assigns(:retain_user))
  end

  def test_should_destroy_retain_user
    assert_difference('RetainUser.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to retain_users_path
  end
end
