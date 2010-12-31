# -*- coding: utf-8 -*-


#    1 - :area_number
#    2 - :branch
#    4 - :problem
#   14 - :customer_name
#   19 - :customer_contact_name
#   22 - :cpu_type
#   23 - :priority
#   27 - :queue_name
#   39 - :cpu_serial_number
#   40 - :component_id
#   41 - :center
#   42 - :comment
#   48 - :business_unit
#   54 - :queue_level
#   77 - :routing_id
#   78 - :support_level
#   89 - :q_or_d
#  101 - :nls_customer_name
#  102 - :nls_contact_name
#  103 - :nls_scratch_pad_1
#  104 - :nls_scratch_pad_2
#  105 - :nls_scratch_pad_3
#  107 - :nls_text_line
#  128 - :nls_comment
#  206 - :user_assigned_problem_flag
#  258 - :release
#  259 - :category
#  262 - :environment
#  273 - :branch_and_country
#  274 - :territory
#  284 - :system_down
#  285 - :call_back_time
#  331 - :addtxt_line
#  332 - :customer_account
#  333 - :dcsf_user_id
#  334 - :dcsf_node_id
#  335 - :user_id
#  336 - :customer_problem
#  339 - :voice_contact_required
#  524 - :director_number
#  537 - :contact_phone_1
#  538 - :contact_phone_2
#  542 - :hardware_territory
#  556 - :next_dispatch_timestamp
#  585 - :operand
#  605 - :caller_type
#  615 - :device_type
#  616 - :device_model
#  617 - :device_serial_field
#  657 - :severity
#  677 - :hardware_severity
#  678 - :dl_log
#  679 - :dl_log_2
#  713 - :name
#  723 - :daylight_savings_time
#  725 - :time_zone_adjustment
# 1239 - :scratch_pad_line_1
# 1240 - :scratch_pad_line_2
# 1241 - :scratch_pad_line_3
# 1253 - :group_request
# 1261 - :global_enterprise_number
# 1263 - :nls_street_address
# 1265 - :nls_city
# 1267 - :nls_state
# 1268 - :zip_code
# 1270 - :external_system_problem
# 1271 - :external_system_country
# 1272 - :iin_account_code
# 1274 - :premium_flag
# 1384 - :error_message
# 1999 - :system_flag
# 2181 - :server_name
# 2209 - :vantive_customer_id
# 2210 - :vantive_email_selector

module Retain
  class Pmce < Sdi
    set_fetch_request "PMCE"
    set_required_fields(:country,
                        :customer_number,
                        :h_or_s,
                        :signon,
                        :password,
                        :problem_create_only)
    set_optional_fields(:area_number,
                        :branch,
                        :problem,
                        :customer_name,
                        :customer_contact_name,
                        :cpu_type,
                        :priority,
                        :queue_name,
                        :cpu_serial_number,
                        :component_id,
                        :center,
                        :comment,
                        :business_unit,
                        :queue_level,
                        :routing_id,
                        :support_level,
                        :q_or_d,
                        :nls_customer_name,
                        :nls_contact_name,
                        :nls_scratch_pad_1,
                        :nls_scratch_pad_2,
                        :nls_scratch_pad_3,
                        :nls_text_line,
                        :nls_comment,
                        :user_assigned_problem_flag,
                        :release,
                        :category,
                        :environment,
                        :branch_and_country,
                        :territory,
                        :system_down,
                        :call_back_time,
                        :addtxt_lines,
                        :customer_account,
                        :dcsf_user_id,
                        :dcsf_node_id,
                        :user_id,
                        :customer_problem,
                        :voice_contact_required,
                        :director_number,
                        :contact_phone_1,
                        :contact_phone_2,
                        :hardware_territory,
                        :next_dispatch_timestamp,
                        :operand,
                        :caller_type,
                        :device_type,
                        :device_model,
                        :device_serial_field,
                        :severity,
                        :hardware_severity,
                        :dl_log,
                        :dl_log_2,
                        :name,
                        :daylight_savings_time,
                        :time_zone_adjustment,
                        :scratch_pad_line_1,
                        :scratch_pad_line_2,
                        :scratch_pad_line_3,
                        :group_request,
                        :global_enterprise_number,
                        :nls_street_address,
                        :nls_city,
                        :nls_state,
                        :zip_code,
                        :external_system_problem,
                        :external_system_country,
                        :iin_account_code,
                        :premium_flag,
                        :error_message,
                        :system_flag,
                        :server_name,
                        :vantive_customer_id,
                        :vantive_email_selector
                        )
    def initialize(params, options = { })
      super(params, options)
      unless @fields.has_key?(:problem_create_only)
        @fields[:problem_create_only] = "N"
      end
    end
  end
end
