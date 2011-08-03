# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

class WelcomeController < ApplicationController
  def index
    @user = application_user
  end
end
