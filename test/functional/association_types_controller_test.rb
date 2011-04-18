require 'test_helper'

class AssociationTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:association_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create association_type" do
    assert_difference('AssociationType.count') do
      post :create, :association_type => { }
    end

    assert_redirected_to association_type_path(assigns(:association_type))
  end

  test "should show association_type" do
    get :show, :id => association_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => association_types(:one).to_param
    assert_response :success
  end

  test "should update association_type" do
    put :update, :id => association_types(:one).to_param, :association_type => { }
    assert_redirected_to association_type_path(assigns(:association_type))
  end

  test "should destroy association_type" do
    assert_difference('AssociationType.count', -1) do
      delete :destroy, :id => association_types(:one).to_param
    end

    assert_redirected_to association_types_path
  end
end
