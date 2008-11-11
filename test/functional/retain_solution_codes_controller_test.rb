require 'test_helper'

class RetainSolutionCodesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:retain_solution_codes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_retain_solution_code
    assert_difference('RetainSolutionCode.count') do
      post :create, :retain_solution_code => { }
    end

    assert_redirected_to retain_solution_code_path(assigns(:retain_solution_code))
  end

  def test_should_show_retain_solution_code
    get :show, :id => retain_solution_codes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => retain_solution_codes(:one).id
    assert_response :success
  end

  def test_should_update_retain_solution_code
    put :update, :id => retain_solution_codes(:one).id, :retain_solution_code => { }
    assert_redirected_to retain_solution_code_path(assigns(:retain_solution_code))
  end

  def test_should_destroy_retain_solution_code
    assert_difference('RetainSolutionCode.count', -1) do
      delete :destroy, :id => retain_solution_codes(:one).id
    end

    assert_redirected_to retain_solution_codes_path
  end
end
