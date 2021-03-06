# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require File.dirname(__FILE__) + '/../test_helper'

class CombinedPsarsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:combined_psars)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_combined_psar
    assert_difference('CombinedPsar.count') do
      post :create, :combined_psar => { }
    end

    assert_redirected_to combined_psar_path(assigns(:combined_psar))
  end

  def test_should_show_combined_psar
    get :show, :id => combined_psars(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => combined_psars(:one).id
    assert_response :success
  end

  def test_should_update_combined_psar
    put :update, :id => combined_psars(:one).id, :combined_psar => { }
    assert_redirected_to combined_psar_path(assigns(:combined_psar))
  end

  def test_should_destroy_combined_psar
    assert_difference('CombinedPsar.count', -1) do
      delete :destroy, :id => combined_psars(:one).id
    end

    assert_redirected_to combined_psars_path
  end
end
