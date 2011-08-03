# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
require 'test_helper'

class RetainNodesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:retain_nodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create retain_node" do
    assert_difference('RetainNode.count') do
      post :create, :retain_node => { }
    end

    assert_redirected_to retain_node_path(assigns(:retain_node))
  end

  test "should show retain_node" do
    get :show, :id => retain_nodes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => retain_nodes(:one).to_param
    assert_response :success
  end

  test "should update retain_node" do
    put :update, :id => retain_nodes(:one).to_param, :retain_node => { }
    assert_redirected_to retain_node_path(assigns(:retain_node))
  end

  test "should destroy retain_node" do
    assert_difference('RetainNode.count', -1) do
      delete :destroy, :id => retain_nodes(:one).to_param
    end

    assert_redirected_to retain_nodes_path
  end
end
