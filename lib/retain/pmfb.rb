# -*- coding: utf-8 -*-

module Retain
  #
  # Allowed in group request:
  #   41: :center
  #   48: :business_unit
  #  565: :software_center
  #  630: :format_panel_number
  #  631: :format_panel
  #  712: :signon2
  #  713: :name
  #  720: :telephone_number
  # 1319: :format_title
  # 1320: :format_line_count
  # 1321: :alter_create_date_sequence
  # 1322: :alter_create_time
  # 1323: :format_chain
  # 1324: :format_line_count_binary
  # 1325: :offset_to_first_input_field
  # 1326: :panel_keyword_table
  # 2133: :formatted_panel_line
  class Pmfb < Retain::Sdi
    set_fetch_request "PMFB"
    set_required_fields(:center, :format_panel_number, :signon, :password)
    set_optional_fields(:panel_operand, :group_request, :error_message)
    
    def initialize(retain_user_connection_parameters, options = { })
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :center,
                                    :business_unit,
                                    :software_center,
                                    :format_panel_number,
                                    :format_panel,
                                    :name,
                                    :telephone_number,
                                    :format_title,
                                    :format_line_count,
                                    :alter_create_date_sequence,
                                    :alter_create_time,
                                    :format_chain,
                                    :format_line_count_binary,
                                    :offset_to_first_input_field,
                                    :panel_keyword_table,
                                    :formatted_panel_line
                                   ]]
      end
    end
  end
end
