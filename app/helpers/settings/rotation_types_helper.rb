module Settings
  module RotationTypesHelper
    def link_to_rotation_types_list(group, label = nil)
      label ||= 'List of Rotation Types'
      link_to(label, settings_rotation_group_rotation_types_path(group))
    end

    def link_to_show_rotation_type(group, type, label = nil)
      label ||= "Show #{type.name}"
      link_to(label, settings_rotation_group_rotation_type_path(group, type))
    end

    def link_to_new_rotation_type(group, label = nil)
      label ||= 'New Rotation Type'
      link_to(label, new_settings_rotation_group_rotation_type_path(group))
    end
    
    def link_to_edit_rotation_type(group, type, label = nil)
      label ||= "Edit #{type.name}"
      link_to(label, edit_settings_rotation_group_rotation_type_path(group, type))
    end

    def link_to_destroy_rotation_type(group, type, label = nil)
      label ||= "Delete Rotation Type #{type.name}"
      link_to('Destroy', settings_rotation_group_rotation_type_path(group, type),
              :confirm => 'Are you sure?', :method => :delete)
    end
  end
end
