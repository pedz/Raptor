# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  module UsersHelper
    def retain_user_list(user)
      user.retusers.all.collect { |r|
        [ "#{r.retid} (#{r.apptest ? "apptest" : "prodution"})", r.id ]
      }
    end

    def link_to_new_user(label = nil)
      label ||= 'New user'
      link_to(label, new_settings_user_path)
    end

    def link_to_users_list(label = nil)
      label ||= 'List of Users'
      link_to(label, settings_users_path)
    end

    def link_to_edit_user(user, label = nil)
      label ||= "Edit #{user.ldap_id}"
      link_to(label, edit_settings_user_path(user))
    end

    def link_to_show_user(user, label = nil)
      label ||= "Show #{user.ldap_id}"
      link_to(label, settings_user_path(user))
    end

    def link_to_destroy_user(user, label = nil)
      label ||= "Delete #{user.ldap_id}"
      link_to(label, settings_user_path(user), :confirm => 'Are you sure?', :method => :delete)
    end

    def link_to_users_retain_id(user)
      if user.current_retain_id.nil?
        if user.retusers.empty?
          link_to('New Retain User Id', new_settings_user_retuser_path(user))
        else
          link_to('Pick Retain Id', edit_settings_user_path(user))
        end
      else
        link_to("#{user.current_retain_id.retid}", settings_user_retuser_path(user, user.current_retain_id))
      end
    end
  end
end
