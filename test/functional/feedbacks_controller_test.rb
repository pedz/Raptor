# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../test_helper'
require 'feedbacks_controller'

# Re-raise errors caught by the controller.
class FeedbacksController; def rescue_action(e) raise e end; end

class FeedbacksControllerTest < Test::Unit::TestCase
  def setup
    @controller = FeedbacksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:feedbacks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_feedback
    assert_difference('Feedback.count') do
      post :create, :feedback => { }
    end

    assert_redirected_to feedback_path(assigns(:feedback))
  end

  def test_should_show_feedback
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_feedback
    put :update, :id => 1, :feedback => { }
    assert_redirected_to feedback_path(assigns(:feedback))
  end

  def test_should_destroy_feedback
    assert_difference('Feedback.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to feedbacks_path
  end
end
