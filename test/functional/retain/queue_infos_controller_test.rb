# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require File.dirname(__FILE__) + '/../../test_helper'
require 'retain/queue_infos_controller'

# Re-raise errors caught by the controller.
class Retain::QueueInfosController; def rescue_action(e) raise e end; end

class Retain::QueueInfosControllerTest < Test::Unit::TestCase
  def setup
    @controller = Retain::QueueInfosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:retain_queue_infos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_queue_info
    assert_difference('Retain::QueueInfo.count') do
      post :create, :queue_info => { }
    end

    assert_redirected_to queue_info_path(assigns(:queue_info))
  end

  def test_should_show_queue_info
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_queue_info
    put :update, :id => 1, :queue_info => { }
    assert_redirected_to queue_info_path(assigns(:queue_info))
  end

  def test_should_destroy_queue_info
    assert_difference('Retain::QueueInfo.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to retain_queue_infos_path
  end
end
