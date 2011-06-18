# -*- coding: utf-8 -*-
require 'test_helper'

class ArgumentTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:argument_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create argument_type" do
    assert_difference('ArgumentType.count') do
      post :create, :argument_type => { }
    end

    assert_redirected_to argument_type_path(assigns(:argument_type))
  end

  test "should show argument_type" do
    get :show, :id => argument_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => argument_types(:one).to_param
    assert_response :success
  end

  test "should update argument_type" do
    put :update, :id => argument_types(:one).to_param, :argument_type => { }
    assert_redirected_to argument_type_path(assigns(:argument_type))
  end

  test "should destroy argument_type" do
    assert_difference('ArgumentType.count', -1) do
      delete :destroy, :id => argument_types(:one).to_param
    end

    assert_redirected_to argument_types_path
  end
end
