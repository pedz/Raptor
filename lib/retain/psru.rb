# -*- coding: utf-8 -*-

# Required:
# 1279  :psar_file_and_symbol
#  or
# 1074  :psar_start_date
# 1135  :h_or_s
# 1278  :psar_remote_write ??? (psar page number)
# And (required)
# 585   :operand "UPD ", "COPY", or "DEL "
# 1236  :signon
# 1237  :password
# Optional:
# 22    :cpu_type
# 39    :cpu_serial_number
# 1076  :stop_time
# 1080  :psar_cia
# 1081  :psar_impact
# 1083  :psar_action_code
# 1088  :psar_cause
# 1091  :psar_fesn
# 1092  :psar_service_code
# 1094  :ipar_mes
# 1096  :ipar_course
# 1097  :psar_fesn_release
# 1100  :psar_solution_code
# 1103  :psar_optional_data
# 1104  :psar_survey
# 1105  :psar_special_activity
# 1106  :psar_other_office
# 1110  :psar_mileage
# 1111  :psar_expense
# 1119  :ipar_technical_activity
# 1122  :psar_apar_number
# 1384  :error_message
# 1386  :call_received_time
# 1387  :actual_local_time
# 1388  :psi_time_hex
# 1389  :travel_time
# 1394  :overtime_hex
# 1395  :travel_overtime_hex
# 1396  :chargeable_time_hex
# 1397  :after_hours_time_hex
# 1398  :local_stop_time_hex
module Retain
  class Psru < Sdi
    set_fetch_request "PSRU"
    set_required_fields(:psar_file_and_symbol,
                        :operand,
                        :signon,
                        :password)
    set_optional_fields(:cpu_type,
                        :cpu_serial_number,
                        :stop_time,
                        :psar_cia,
                        :psar_impact,
                        :psar_action_code,
                        :psar_cause,
                        :psar_fesn,
                        :psar_service_code,
                        :ipar_mes,
                        :ipar_course,
                        :psar_fesn_release,
                        :psar_solution_code,
                        :psar_optional_data,
                        :psar_survey,
                        :psar_special_activity,
                        :psar_other_office,
                        :psar_mileage,
                        :psar_expense,
                        :ipar_technical_activity,
                        :psar_apar_number,
                        :error_message,
                        :call_received_time,
                        :actual_local_time,
                        :psi_time_hex,
                        :travel_time,
                        :overtime_hex,
                        :travel_overtime_hex,
                        :chargeable_time_hex,
                        :after_hours_time_hex,
                        :local_stop_time_hex)

    def initialize(params, options = {})
      super(params, options)
    end
  end
end
