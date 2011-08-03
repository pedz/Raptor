# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class RetainNodeSelectorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:retain_node_selectors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create retain_node_selector" do
    assert_difference('RetainNodeSelector.count') do
      post :create, :retain_node_selector => { }
    end

    assert_redirected_to retain_node_selector_path(assigns(:retain_node_selector))
  end

  test "should show retain_node_selector" do
    get :show, :id => retain_node_selectors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => retain_node_selectors(:one).to_param
    assert_response :success
  end

  test "should update retain_node_selector" do
    put :update, :id => retain_node_selectors(:one).to_param, :retain_node_selector => { }
    assert_redirected_to retain_node_selector_path(assigns(:retain_node_selector))
  end

  test "should destroy retain_node_selector" do
    assert_difference('RetainNodeSelector.count', -1) do
      delete :destroy, :id => retain_node_selectors(:one).to_param
    end

    assert_redirected_to retain_node_selectors_path
  end
end
