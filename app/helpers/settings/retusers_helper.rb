# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  module RetusersHelper
    def node_selector_list(test_mode, node_type)
      RetainNodeSelector.
        find(:all,
             :joins => [ :retain_node ],
             :conditions => {
               "retain_nodes.apptest" => test_mode,
               "retain_nodes.node_type" => node_type
             }).
        collect { |n|
        [ n.description, n.id ]
      }
    end

    def link_to_list_retusers(user, label = nil)
      label ||= 'List of Retain Ids'
      link_to(label, settings_user_retusers_path(user))
    end

    def link_to_show_retuser(user, retuser, label = nil)
      label ||= "Show Retain User #{retuser.retid}"
      link_to(label, settings_user_retuser_path(user, retuser))
    end

    def link_to_create_retuser(user, label = nil)
      label ||= "Create New Retain User Id for #{user.ldap_id}"
      link_to(label, new_settings_user_retuser_path(user))
    end
    
    def link_to_edit_retuser(user, retuser, label = nil)
      label ||= "Edit Retain User #{retuser.retid}"
      link_to(label, edit_settings_user_retuser_path(user, retuser))
    end

    def link_to_destroy_retuser(user, retuser, label = nil)
      label ||= "Delete Retain User #{retuser.retid}"
      link_to(label, settings_user_retuser_path(user, retuser),
              :confirm => 'Are you sure?', :method => :delete)
    end
  end
end
