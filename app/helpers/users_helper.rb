# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module UsersHelper
  def retain_user_list(user)
    user.retusers.all.collect { |r|
      [ "#{r.retid} (#{r.apptest ? "apptest" : "prodution"})", r.id ]
    }
  end
end
