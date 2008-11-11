#
# Possible optional fields
#
#    2 Branch Office
#    3 Country
#    4 Problem Number
#   22 Machine (CPU) Type
#   27 Queue
#   39 Machine (CPU) Serial
#   41 Center
#  550 Priority and Page Number for call record symbol
#  578 Call Class
#  579 Call Disposition
#  580 DB Effectiveness - IPAR only
#  581 DL Effectiveness - IPAR only
#  583 Call Survey
#  586 Second RETAIN Signon - PSAR only
# 1033 Problem Source ID (PSI) Time - in Hours and Tenths (HT) - PSAR
#      only
# 1034 Travel Overtime - in Hours and Tenths (HT)
# 1076 Stop Time - in GMT Minute Of Century (MOC)
# 1080 CIA (Status)
# 1081 Impact Code - PSAR only
# 1083 Action Code
# 1088 Cause Code for PSAR or Activity Code for IPAR
# 1091 FESN -PSAR only
# 1093 Overtime - in Hours and Tenths (HT)
# 1094 MES/ECA# - IPAR only
# 1095 Local Stop Date (MM/DD/YY)
# 1096 Course Number for IPAR, Project for PSAR - not allowed for
#      problem PSAR's
# 1097 Release Number - PSAR only
# 1100 Solution Code (Relief Indicator) - PSAR only
# 1103 Optional Data - PSAR only
# 1104 Survey - PSAR only
# 1105 Special Activity
# 1106 Other Office
# 1109 Travel Time - in Hours and Tenths (HT)
# 1110 Mileage
# 1111 Expense
# 1112 Local Stop Time - in Hours and Tenths (HHT)
# 1113 Actual Local Time - in Hours and Tenths (HT)
# 1114 Call Received time - in Hours and Tenths (HHT) - not allowed
#      for Requeue or Complete - PSAR only
# 1119 Technical Activity Code - IPAR only
# 1122 APAR/PTF or Tape Number - PSAR only
# 1135 HW/SW indicator
# 1275 Chargeable Time (HHMM) HH in Hex and MM in Hex - PSAR only
# 1276 After Hours Time (HHMM) HH in Hex and MM in Hex - PSAR only
# 1384 Error Message to return to remote system
# 1386 Call Received Time - Minutes in Hex - PSAR only
# 1387 Actual Local Time - Minutes in Hex
# 1388 Problem Source ID (PSI) Time - Minutes in Hex - PSAR only
# 1389 Travel Time - Minutes in Hex
# 1394 Overtime - Minutes in Hex
# 1395 Travel Overtime - Minutes in Hex
# 1396 Chargeable Time - Minutes in Hex - PSAR only
# 1397 After Hours Time - Minutes in Hex - PSAR only
# 1398 Local Stop Time - Minutes in Hex

module Retain
  class Psrc < Sdi
    set_fetch_request "PSRC"
    set_required_fields(:signon, :password, :psar_service_code)
    set_optional_fields(:branch,
                        :country,
                        :problem,
                        :cpu_type,
                        :queue_name,
                        :cpu_serial_number,
                        :center,
                        :ppg,
                        :call_class,
                        :call_disposition,
                        :data_bank_use_code,
                        :data_link_use_code,
                        :call_survey_code,
                        :secondary_login,
                        :psi_time_ht,
                        :travel_overtime,
                        :stop_time,
                        :psar_cia,
                        :psar_impact,
                        :psar_action_code,
                        :psar_cause,
                        :psar_fesn,
                        :overtime,
                        :ipar_mes,
                        :local_stop_date,
                        :ipar_course,
                        :psar_fesn_release,
                        :psar_solution_code,
                        :psar_optional_data,
                        :psar_survey,
                        :psar_special_activity,
                        :psar_other_office,
                        :psar_travel_time,
                        :psar_mileage,
                        :psar_expense,
                        :psar_activity_stop_time,
                        :psar_actual_time,
                        :psar_call_received_time,
                        :ipar_technical_activity,
                        :psar_apar_number,
                        :h_or_s,
                        :psar_chargeable_time,
                        :psar_chargeable_after_hour,
                        :error_message,
                        :call_received_time,
                        :actual_local_time,
                        :psi_time_hex,
                        :travel_time,
                        :overtime_hex,
                        :travel_overtime_hex,
                        :chargeable_time_hex,
                        :after_hours_time_hex,
                        :local_stop_time_hex
                        )

    def initialize(options = {})
      super(options)
    end
  end
end
