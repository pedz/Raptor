# Fields which can be requested.
#
#    2 -- :branch
#    3 -- :country
#    4 -- :problem
#   11 -- :customer_number
#   22 -- :cpu_type
#   39 -- :cpu_serial_number
#  712 -- :signon2
#  920 -- :minutes_from_gmt
#  931 -- :cpu_origin
#  932 -- :processor_serial_number
# 1079 -- :psar_record_id
# 1080 -- :psar_cia
# 1081 -- :psar_impact
# 1083 -- :psar_action_code
# 1084 -- :ipar_action
# 1085 -- :ipar_action_code
# 1086 -- :psar_site
# 1087 -- :psar_system_date
# 1088 -- :psar_cause
# 1089 -- :psar_stop_date_year
# 1090 -- :psar_activity_date
# 1091 -- :psar_fesn
# 1092 -- :psar_service_code
# 1094 -- :ipar_mes
# 1096 -- :ipar_course
# 1097 -- :psar_fesn_release
# 1098 -- :psar_apar
# 1100 -- :psar_solution_code
# 1101 -- :psar_location
# 1102 -- :psar_territory
# 1103 -- :psar_optional_data
# 1104 -- :psar_survey
# 1105 -- :psar_special_activity
# 1106 -- :psar_other_office
# 1107 -- :psar_overtime_indicator
# 1108 -- :psar_support_level
# 1109 -- :psar_travel_time
# 1110 -- :psar_mileage
# 1111 -- :psar_expense
# 1112 -- :psar_activity_stop_time
# 1113 -- :psar_actual_time
# 1114 -- :psar_call_received_time
# 1115 -- :psar_users_time_zone_adj
# 1116 -- :psar_unique_sequence
# 1117 -- :psar_alphabetic_id
# 1118 -- :psar_julian
# 1119 -- :ipar_technical_activity
# 1120 -- :psar_sequence_number
# 1121 -- :psar_mailed_flag
# 1122 -- :psar_apar_number
# 1123 -- :psar_user_country
# 1124 -- :psar_user_branch
# 1125 -- :psar_user_shift
# 1126 -- :psar_user_shift_stop
# 1127 -- :psar_bill_control
# 1128 -- :psar_mabo
# 1129 -- :psar_customer_number
# 1258 -- :psar_flag_byte
# 1259 -- :psar_problem_open_moc
# 1260 -- :psar_chargeable_src_ind
# 1264 -- :chargeable_queue_name
# 1269 -- :chargeable_center
# 1275 -- :psar_chargeable_time
# 1276 -- :psar_chargeable_after_hour
# 1278 -- :psar_remote_write
# 1279 -- :psar_file_and_symbol
# 1399 -- :stop_time_moc



module Retain
  class Psrr < Sdi
    set_fetch_request "PSRR"
    set_required_fields(:signon, :password, :group_request)
    set_optional_fields(:psar_start_date,
                        :psar_end_date,
                        :h_or_s,
                        :psar_file_and_symbol,
                        :error_message)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :signon2,
                                    :minutes_from_gmt,
                                    :psar_sequence_number,
                                    :psar_mailed_flag,
                                    :problem,
                                    :branch,
                                    :country,
                                    :cpu_type,
                                    :cpu_serial_number,
                                    :psar_file_and_symbol,
                                    :psar_fesn,
                                    :psar_service_code,
                                    :psar_action_code,
                                    :psar_cause,
                                    :psar_impact,
                                    :psar_solution_code,
                                    :psar_cia,
                                    :psar_apar,
                                    :psar_system_date,
                                    :psar_activity_date,
                                    :psar_actual_time,
                                    :psar_chargeable_src_ind,
                                    :chargeable_queue_name,
                                    :chargeable_center,
                                    :psar_chargeable_time,
                                    :psar_chargeable_after_hour,
                                    :chargeable_time_hex,
                                    :after_hours_time_hex,
                                    :psar_stop_date_year,
                                    :psar_activity_stop_time,
                                    :psar_user_shift_stop,
                                    :stop_time_moc
                                   ]]
      end
    end
  end
end
