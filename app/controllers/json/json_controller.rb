# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Json
  class JsonController < ApplicationController
    # Even in development, I want this so that JSON errors do not get
    # cached but we only need to add it if we are in development
    # because ApplicationController adds it in the other environments.
    if Rails.env == "development"
      rescue_from Exception, :with => :uncaught_exception
    end
    include JsonCommon
  end
end
