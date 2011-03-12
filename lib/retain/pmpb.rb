# -*- coding: utf-8 -*-

#    1 -- :area_number
#    2 -- :branch
#    3 -- :country
#    4 -- :problem
#   11 -- :customer_number
#   14 -- :customer_name
#   19 -- :customer_contact_name
#   22 -- :cpu_type
#   23 -- :priority
#   27 -- :queue_name
#   39 -- :cpu_serial_number
#   40 -- :component_id
#   41 -- :center
#   42 -- :comment
#   54 -- :queue_level
#   87 -- :creator_serial
#   89 -- :q_or_d
#  101 -- :nls_customer_name
#  102 -- :nls_contact_name
#  103 -- :nls_scratch_pad_1
#  104 -- :nls_scratch_pad_2
#  105 -- :nls_scratch_pad_3
#  106 -- :nls_scratch_pad_signature
#  107 -- :nls_text_line
#  118 -- :nls_user_keyword
#  121 -- :nominate_flag
#  128 -- :nls_comment
#  131 -- :author_type
#  132 -- :owning_retain_node
#  133 -- :nls_pmr_owner_name
#  134 -- :pmr_owner_phone
#  135 -- :pmr_owner_id
#  136 -- :pmr_owner_territory
#  141 -- :pmr_owner_name
#  186 -- :sec_1_queue
#  187 -- :sec_1_center
#  188 -- :sec_1_ppg
#  189 -- :sec_1_h_or_s
#  190 -- :sec_2_queue
#  191 -- :sec_2_center
#  192 -- :sec_2_ppg
#  193 -- :sec_2_h_or_s
#  194 -- :sec_3_queue
#  195 -- :sec_3_center
#  196 -- :sec_3_ppg
#  197 -- :sec_3_h_or_s
#  226 -- :family_offering
#  249 -- :premium_response
#  250 -- :severity_changeable
#  251 -- :voice_response_entitled
#  256 -- :support_center_country
#  258 -- :release
#  259 -- :category
#  260 -- :system_tape
#  261 -- :component_tape
#  262 -- :environment
#  273 -- :branch_and_country
#  274 -- :territory
#  275 -- :previous_center
#  276 -- :previous_queue
#  277 -- :previous_priority
#  278 -- :previous_level
#  279 -- :previous_category
#  331 -- :addtxt_line
#  332 -- :customer_account
#  333 -- :dcsf_user_id
#  334 -- :dcsf_node_id
#  335 -- :user_id
#  336 -- :customer_problem
#  340 -- :alterable_format_line
#  341 -- :formatted_panel_area
#  537 -- :contact_phone_1
#  538 -- :contact_phone_2
#  539 -- :fup_control_count
#  540 -- :askq_control_flag
#  541 -- :special_application
#  542 -- :hardware_territory
#  550 -- :ppg
#  551 -- :comp_id_or_alias
#  552 -- :pmr_status_watermark
#  605 -- :caller_type
#  610 -- :problem_status_code
#  612 -- :region_number_watermark
#  615 -- :device_type
#  616 -- :device_model
#  617 -- :device_serial_field
#  618 -- :target_date
#  619 -- :engineering_change
#  620 -- :network_area
#  621 -- :world_trade_region_number
#  633 -- :number_of_private_page
#  634 -- :extra_bit
#  635 -- :country_watermark
#  636 -- :branch_watermark
#  639 -- :country_number_watermark
#  640 -- :area_watermark
#  643 -- :business_unit_watermark
#  646 -- :creation_date
#  647 -- :creation_time
#  648 -- :alteration_date
#  649 -- :alteration_time
#  650 -- :apar_number
#  651 -- :current_text_start
#  652 -- :follow_up_info
#  657 -- :severity
#  660 -- :sec_call_symbol_1
#  661 -- :sec_call_symbol_2
#  662 -- :sec_call_symbol_3
#  663 -- :special_option_1
#  664 -- :special_option_2
#  665 -- :special_option_3
#  666 -- :special_option_4
#  667 -- :special_option_5
#  668 -- :network_number
#  669 -- :special_option_6
#  672 -- :controlled_flag
#  674 -- :traced_product
#  675 -- not documented
#  677 -- :hardware_severity
#  678 -- :dl_log
#  679 -- :dl_log_2
#  680 -- :problem_record_flag
#  681 -- :special_offering_flag
#  682 -- :problem_record_flags_2
#  683 -- :previous_severity
#  684 -- :original_severity
#  685 -- :country_number
#  686 -- :branch_office
#  687 -- :country_watermark
#  692 -- :next_queue
#  693 -- :next_center
#  694 -- :extra_flag
#  696 -- :serial_number_watermark
#  698 -- :rsf_flag
#  699 -- :model_308x_save_area
#  701 -- :poc_control_node
#  702 -- :associated_data_key
#  703 -- :associated_data_copy_list
#  704 -- :bitstring
#  705 -- :problem_create_poc
#  706 -- :call_count
#  707 -- :symbol_of_call_record
#  708 -- :purge_control_flag
#  709 -- :last_service_code
#  710 -- :call_problem_threshold
#  711 -- :author_id
#  930 -- :iris
# 1135 -- :h_or_s
# 1238 -- :scratch_pad_signature
# 1239 -- :scratch_pad_line_1
# 1240 -- :scratch_pad_line_2
# 1241 -- :scratch_pad_line_3
# 1242 -- :problem_type_code
# 1243 -- :alternate_location
# 1244 -- :action_code
# 1245 -- :action_code_2
# 1246 -- :askq_item_number
# 1247 -- :action_code_entered
# 1248 -- :survey_code
# 1249 -- :askq_status_flag
# 1250 -- :division
# 1251 -- :askq_country_watermark
# 1252 -- :user_binary_id
# 1254 -- :sub_function_control
# 1255 -- :xcel_contract_number
# 1256 -- :flag_byte
# 1261 -- :global_enterprise_number
# 1262 -- :seven_special_option
# 1263 -- :nls_street_address
# 1265 -- :nls_city
# 1266 -- :city_expansion
# 1267 -- :nls_state
# 1268 -- :zip_code
# 1270 -- :external_system_problem
# 1271 -- :external_system_country
# 1272 -- :iin_account_code
# 1273 -- :last_alter_timestamp
# 1312 -- :nls_family_abstract
# 1390 -- :information_text_line
# 1393 -- :total_page
# 2150 -- :problem_flag_bit
# 2151 -- :invalid_reason_code
# 2152 -- :component_id_or_device
# 2153 -- :onsite_prob_det_required
# 2154 -- :expected_duration
# 2155 -- :target_arrival_time
# 2156 -- :m_s_branch_office
# 2157 -- :part_number
# 2158 -- :ecco_problem
# 2159 -- :special_message
# 2160 -- :contract
# 2161 -- :bid_number
# 2162 -- :service_contract
# 2163 -- :customer_claimed_contract
# 2164 -- :contract_type
# 2165 -- :origin_id
# 2166 -- :customer_problem_number
# 2167 -- :contract_hour
# 2168 -- :service_hour
# 2169 -- :authorized_name
# 2170 -- :authorized_phone_number
# 2171 -- :cmr_customer_number
# 2209 -- :vantive_customer_id
# 2210 -- :vantive_email_selector
# 2221 -- :service_request
# 2417 -- :request_type
# 2418 -- :request_type_description
# 2419 -- :sub_request_type
# 2420 -- :sub_request_description
# 2421 -- :entitlement_code
# 2422 -- :contract_number
# 2423 -- :pid_number
# 2425 -- :vrm

module Retain
  class Pmpb < Sdi
    set_fetch_request "PMPB"
    set_required_fields(:problem, :branch, :country,
                        :signon, :password,
                        :group_request)
    set_optional_fields(:beginning_page_number)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :queue_name,
                                    :center,
                                    :h_or_s,
                                    :ppg,
                                    :priority,
                                    :severity,
                                    :p_s_b,
                                    :comments,
                                    :nls_customer_name,
                                    :cstatus,
                                    :nls_scratch_pad_1,
                                    :nls_scratch_pad_2,
                                    :nls_scratch_pad_3,
                                    :addtxt_lines,
                                    :information_text_lines,
                                    :alterable_format_lines
                                   ]]
      end
    end
  end
end
