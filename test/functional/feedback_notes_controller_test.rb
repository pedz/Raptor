# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

require File.dirname(__FILE__) + '/../test_helper'
require 'feedback_notes_controller'

# Re-raise errors caught by the controller.
class FeedbackNotesController; def rescue_action(e) raise e end; end

class FeedbackNotesControllerTest < Test::Unit::TestCase
  def setup
    @controller = FeedbackNotesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:feedback_notes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_feedback_note
    assert_difference('FeedbackNote.count') do
      post :create, :feedback_note => { }
    end

    assert_redirected_to feedback_note_path(assigns(:feedback_note))
  end

  def test_should_show_feedback_note
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_feedback_note
    put :update, :id => 1, :feedback_note => { }
    assert_redirected_to feedback_note_path(assigns(:feedback_note))
  end

  def test_should_destroy_feedback_note
    assert_difference('FeedbackNote.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to feedback_notes_path
  end
end
