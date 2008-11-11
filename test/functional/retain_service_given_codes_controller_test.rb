require 'test_helper'

class RetainServiceGivenCodesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:retain_service_given_codes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_retain_service_given_code
    assert_difference('RetainServiceGivenCode.count') do
      post :create, :retain_service_given_code => { }
    end

    assert_redirected_to retain_service_given_code_path(assigns(:retain_service_given_code))
  end

  def test_should_show_retain_service_given_code
    get :show, :id => retain_service_given_codes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => retain_service_given_codes(:one).id
    assert_response :success
  end

  def test_should_update_retain_service_given_code
    put :update, :id => retain_service_given_codes(:one).id, :retain_service_given_code => { }
    assert_redirected_to retain_service_given_code_path(assigns(:retain_service_given_code))
  end

  def test_should_destroy_retain_service_given_code
    assert_difference('RetainServiceGivenCode.count', -1) do
      delete :destroy, :id => retain_service_given_codes(:one).id
    end

    assert_redirected_to retain_service_given_codes_path
  end
end
