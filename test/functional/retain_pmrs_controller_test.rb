require File.dirname(__FILE__) + '/../test_helper'
require 'retain_pmrs_controller'

# Re-raise errors caught by the controller.
class RetainPmrsController; def rescue_action(e) raise e end; end

class RetainPmrsControllerTest < Test::Unit::TestCase
  fixtures :retain_pmrs

  def setup
    @controller = RetainPmrsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:retain_pmrs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_retain_pmr
    assert_difference('RetainPmr.count') do
      post :create, :retain_pmr => { }
    end

    assert_redirected_to retain_pmr_path(assigns(:retain_pmr))
  end

  def test_should_show_retain_pmr
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_retain_pmr
    put :update, :id => 1, :retain_pmr => { }
    assert_redirected_to retain_pmr_path(assigns(:retain_pmr))
  end

  def test_should_destroy_retain_pmr
    assert_difference('RetainPmr.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to retain_pmrs_path
  end
end
