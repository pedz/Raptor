require 'test_helper'

class RetainServiceActionCauseTuplesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:retain_service_action_cause_tuples)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_retain_service_action_cause_tuple
    assert_difference('RetainServiceActionCauseTuple.count') do
      post :create, :retain_service_action_cause_tuple => { }
    end

    assert_redirected_to retain_service_action_cause_tuple_path(assigns(:retain_service_action_cause_tuple))
  end

  def test_should_show_retain_service_action_cause_tuple
    get :show, :id => retain_service_action_cause_tuples(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => retain_service_action_cause_tuples(:one).id
    assert_response :success
  end

  def test_should_update_retain_service_action_cause_tuple
    put :update, :id => retain_service_action_cause_tuples(:one).id, :retain_service_action_cause_tuple => { }
    assert_redirected_to retain_service_action_cause_tuple_path(assigns(:retain_service_action_cause_tuple))
  end

  def test_should_destroy_retain_service_action_cause_tuple
    assert_difference('RetainServiceActionCauseTuple.count', -1) do
      delete :destroy, :id => retain_service_action_cause_tuples(:one).id
    end

    assert_redirected_to retain_service_action_cause_tuples_path
  end
end
