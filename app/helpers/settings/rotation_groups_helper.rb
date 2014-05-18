# -*- coding: utf-8 -*-
#
# Copyright 2007-2014 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Settings
  module RotationGroupsHelper
    def link_to_rotation_groups_list(label = nil)
      label ||= 'List of Rotation Groups'
      link_to(label, settings_rotation_groups_path)
    end

    def link_to_show_rotation_group(group, label = nil)
      label ||= "Show #{group.name}"
      link_to(label, settings_rotation_group_path(group))
    end

    def link_to_new_rotation_group(label = nil)
      label ||= 'New Rotation Group'
      link_to(label, new_settings_rotation_group_path)
    end
    
    def link_to_edit_rotation_group(group, label = nil)
      label ||= "Edit #{group.name}"
      link_to(label, edit_settings_rotation_group_path(group))
    end

    def link_to_destroy_rotation_group(group, label = nil)
      label ||= "Delete Rotation Group #{group.name}"
      link_to('Destroy', settings_rotation_group_path(group), :confirm => 'Are you sure?', :method => :delete)
    end
  end
end
