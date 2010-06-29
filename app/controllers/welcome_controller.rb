# -*- coding: utf-8 -*-

class WelcomeController < ApplicationController
  def index
    @user = application_user
  end
end
