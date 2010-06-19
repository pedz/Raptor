# -*- coding: utf-8 -*-

module UsersHelper
  def retain_user_list(user)
    user.retusers.all.collect { |r|
      [ "#{r.retid} (#{r.apptest ? "apptest" : "prodution"})", r.id ]
    }
  end
end
