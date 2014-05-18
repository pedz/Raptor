# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  module RotationGroupMembersHelper
    def link_to_new_group_member(group, label = nil)
      label ||= "New member for #{group.name}"
      link_to(label,
              new_settings_rotation_group_rotation_group_member_path(group))
    end

    def link_to_group_members_list(group, label = nil)
      label ||= "List of Members of #{group.name}"
      link_to(label, settings_rotation_group_rotation_group_members_path(group))
    end

    def link_to_show_group_member(group, member, label = nil)
      label ||= "Show #{member.name}"
      link_to(label, settings_rotation_group_rotation_group_member_path(group, member))
    end

    def link_to_edit_group_member(group, member, label = nil)
      label ||= "Edit #{member.name}"
      link_to(label, edit_settings_rotation_group_rotation_group_member_path(group, member))
    end

    def link_to_destroy_group_member(group, member, label = nil)
      label ||= "Delete #{member.name} from #{group.name}"
      link_to(label,
              settings_rotation_group_rotation_group_member_path(group, member),
              :confirm => 'Are you sure?', :method => :delete)
    end
  end
end
