# -*- coding: utf-8 -*-
require 'test_helper'

class NameTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:name_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create name_type" do
    assert_difference('NameType.count') do
      post :create, :name_type => { }
    end

    assert_redirected_to name_type_path(assigns(:name_type))
  end

  test "should show name_type" do
    get :show, :id => name_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => name_types(:one).to_param
    assert_response :success
  end

  test "should update name_type" do
    put :update, :id => name_types(:one).to_param, :name_type => { }
    assert_redirected_to name_type_path(assigns(:name_type))
  end

  test "should destroy name_type" do
    assert_difference('NameType.count', -1) do
      delete :destroy, :id => name_types(:one).to_param
    end

    assert_redirected_to name_types_path
  end
end
