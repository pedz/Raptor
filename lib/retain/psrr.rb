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
                                    :stop_time_moc,
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
                                    :psar_solution,
                                    :psar_cia,
                                    :psar_apar,
                                    :psar_activity_stop_time,
                                    :psar_system_date,
                                    :psar_stop_date_year,
                                    :psar_activity_date,
                                    :psar_actual_time,
                                    :psar_chargeable_src_ind,
                                    :chargeable_queue_name,
                                    :chargeable_center,
                                    :psar_chargeable_time,
                                    :psar_chargeable_after_hour,
                                    :chargeable_time_hex,
                                    :after_hours_time_hex
                                   ]]
      end
    end
  end
end
