# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class MembershipTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:membership_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create membership_type" do
    assert_difference('MembershipType.count') do
      post :create, :membership_type => { }
    end

    assert_redirected_to membership_type_path(assigns(:membership_type))
  end

  test "should show membership_type" do
    get :show, :id => membership_types(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => membership_types(:one).to_param
    assert_response :success
  end

  test "should update membership_type" do
    put :update, :id => membership_types(:one).to_param, :membership_type => { }
    assert_redirected_to membership_type_path(assigns(:membership_type))
  end

  test "should destroy membership_type" do
    assert_difference('MembershipType.count', -1) do
      delete :destroy, :id => membership_types(:one).to_param
    end

    assert_redirected_to membership_types_path
  end
end
