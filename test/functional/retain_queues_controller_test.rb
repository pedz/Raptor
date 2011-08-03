# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require File.dirname(__FILE__) + '/../test_helper'
require 'retain_queues_controller'

# Re-raise errors caught by the controller.
class RetainQueuesController; def rescue_action(e) raise e end; end

class RetainQueuesControllerTest < Test::Unit::TestCase
  fixtures :retain_queues

  def setup
    @controller = RetainQueuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:retain_queues)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_retain_queue
    assert_difference('RetainQueue.count') do
      post :create, :retain_queue => { }
    end

    assert_redirected_to retain_queue_path(assigns(:retain_queue))
  end

  def test_should_show_retain_queue
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_retain_queue
    put :update, :id => 1, :retain_queue => { }
    assert_redirected_to retain_queue_path(assigns(:retain_queue))
  end

  def test_should_destroy_retain_queue
    assert_difference('RetainQueue.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to retain_queues_path
  end
end
