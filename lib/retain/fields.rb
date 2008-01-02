
#
# Right now, the Fields class is just a place to put constants that
# mnemonically map to the data element fields.

module Retain
  class Fields
    #
    # A hash used to create the getters and setters in request and
    # reply.  Also used to create upper case constant equivalents.
    #
    FIELD_DEFINITIONS = {
      :area_number                 => [    1, :ebcdic,          2 ],
      :branch                      => [    2, :upper_ebcdic,    3 ],
      :country                     => [    3, :upper_ebcdic,    3 ],
      :problem                     => [    4, :upper_ebcdic,    5 ],
      :customer_number             => [   11, :upper_ebcdic,    7 ],
      :customer_name               => [   14, :ebcdic,         28 ],
      :customer_contact_name       => [   19, :ebcdic,         28 ],
      :cpu_type                    => [   22, :ebcdic,          4 ],
      :priority                    => [   23, :ebcdic,          1 ],
      :queue_name                  => [   27, :upper_ebcdic,    6 ],
      :de32                        => [   32, :binary,          0 ],
      :cpu_serial_number           => [   39, :ebcdic,          7 ],
      :component_id                => [   40, :ebcdic,         12 ],
      :center                      => [   41, :upper_ebcdic,    3 ],
      :comments                    => [   42, :ebcdic,         54 ],
      :business_unit               => [   48, :ebcdic,          3 ],
      :queue_level                 => [   54, :ebcdic,          1 ],
      :creator_serial              => [   87, :ebcdic,         87 ],
      :q_or_d                      => [   89, :ebcdic,          1 ],
      :nls_creator_name            => [   97, :nls,            30 ],
      :nls_customer_name           => [  101, :nls,            30 ],
      :nls_contact_name            => [  102, :nls,            30 ],
      :nls_scratch_pad_1           => [  103, :nls,            74 ],
      :nls_scratch_pad_2           => [  104, :nls,            74 ],
      :nls_scratch_pad_3           => [  105, :nls,            74 ],
      :nls_text_lines              => [  107, :nls_text_lines, 74 ],
      :nls_user_keyword            => [  118, :ebcdic,         16 ],
      :nominate_flag               => [  121, :ebcdic,          1 ],
      :nls_comments                => [  128, :nls,            56 ],
      :author_type                 => [  131, :ebcdic,          1 ],
      :owning_retain_node          => [  132, :ebcdic,          3 ],
      :nls_pmr_owner_name          => [  133, :nls,            24 ],
      :pmr_owner_phone             => [  134, :ebcdic,         19 ],
      :pmr_owner_employee_number   => [  135, :ebcdic,          6 ],
      :pmr_owner_territory         => [  136, :ebcdic,          3 ],
      :pmr_owner_name              => [  141, :ebcdic,         22 ],
      :sec_1_queue                 => [  186, :ebcdic,          6 ],
      :sec_1_center                => [  187, :ebcdic,          3 ],
      :sec_1_ppg                   => [  188, :ebcdic,          2 ],
      :sec_1_h_or_s                => [  189, :ebcdic,          1 ],
      :sec_2_queue                 => [  190, :ebcdic,          6 ],
      :sec_2_center                => [  191, :ebcdic,          3 ],
      :sec_2_ppg                   => [  192, :ebcdic,          2 ],
      :sec_2_h_or_s                => [  193, :ebcdic,          1 ],
      :sec_3_queue                 => [  194, :ebcdic,          6 ],
      :sec_3_center                => [  195, :ebcdic,          3 ],
      :sec_3_ppg                   => [  196, :ebcdic,          2 ],
      :sec_3_h_or_s                => [  197, :ebcdic,          1 ],
      :family_offering             => [  226, :ebcdic,         12 ],
      :ret_sys_inserted_flag       => [  232, :ebcdic,          1 ],
      :ret_sys_text_and_signature  => [  233, :ebcdic,          1 ],
      :return_signature_line_tail  => [  234, :ebcdic,          1 ],
      :change_sig_line_name_flag   => [  235, :ebcdic,          1 ],
      :premium_response            => [  249, :ebcdic,          1 ],
      :severity_changeable         => [  250, :ebcdic,          1 ],
      :voice_response_entitled     => [  251, :ebcdic,          1 ],
      :support_center_country      => [  256, :ebcdic,          3 ],
      :release                     => [  258, :ebcdic,          3 ],
      :category                    => [  259, :ebcdic,          3 ],
      :system_tape                 => [  260, :ebcdic,          4 ],
      :component_tape              => [  261, :ebcdic,          4 ],
      :environment                 => [  262, :ebcdic,         18 ],
      :branch_and_country          => [  273, :ebcdic,          6 ],
      :territory                   => [  274, :ebcdic,        274 ],
      :previous_center             => [  275, :ebcdic,          3 ],
      :previous_queue              => [  276, :ebcdic,          6 ],
      :previous_priority           => [  277, :ebcdic,          1 ],
      :previous_level              => [  278, :ebcdic,          1 ],
      :previous_category           => [  279, :ebcdic,          3 ],
      :call_complete_code          => [  280, :ebcdic,          1 ],
      :crit_sit                    => [  282, :upper_ebcdic,    1 ],
      :critical_situation          => [  284, :ebcdic,          1 ],
      :call_back_time              => [  285, :ebcdic,          1 ],
      :entered_by_employee         => [  293, :ebcdic,          6 ],
      :p_s_b                       => [  298, :upper_ebcdic,    1 ],
      :dispatched_by_center        => [  301, :ebcdic,          3 ],
      :requeue_center              => [  305, :ebcdic,          3 ],
      :requeue_employee            => [  306, :ebcdic,          6 ],
      :call_symbol                 => [  316, :binary,         12 ],
      :addtxt_lines                => [  331, :text_lines,     72 ],
      :customer_account            => [  332, :ebcdic,        332 ],
      :dcsf_user_id                => [  333, :ebcdic,        333 ],
      :dcsf_node_id                => [  334, :ebcdic,          8 ],
      :user_id                     => [  335, :ebcdic,        335 ],
      :customer_problem            => [  336, :ebcdic,         14 ],
      :alterable_format_text_lines => [  340, :text_lines,     72 ],
      :formatted_panel_area        => [  341, :ebcdic,         20 ],
      :corporate_entity            => [  510, :ebcdic,        510 ],
      :director_number             => [  524, :ebcdic,          4 ],
      :dispatched_employee         => [  525, :ebcdic,          6 ],
      :pre_assigned_employee       => [  526, :ebcdic,          6 ],
      :requested_elements          => [  528, :binary,          0 ],
      :call_queue_status_flags     => [  536, :ebcdic,          1 ],
      :contact_phone_1             => [  537, :ebcdic,         19 ],
      :contact_phone_2             => [  538, :ebcdic,         19 ],
      :fup_control_count           => [  539, :ebcdic,          1 ],
      :askq_control_flags          => [  540, :ebcdic,          1 ],
      :special_application         => [  541, :ebcdic,          1 ],
      :hardware_territory          => [  542, :ebcdic,          3 ],
      :call_control_flag_1         => [  543, :ebcdic,          1 ],
      :call_queue_status_flag      => [  544, :ebcdic,          1 ],
      :original_queue              => [  545, :ebcdic,          6 ],
      :original_level              => [  546, :ebcdic,          1 ],
      :original_center             => [  547, :ebcdic,          3 ],
      :original_category           => [  548, :ebcdic,          3 ],
      :original_priority           => [  549, :ebcdic,          1 ],
      :ppg                         => [  550, :ppg,             2 ],
      :comp_id_or_alias            => [  551, :ebcdic,         12 ],
      :pmr_status_watermark        => [  552, :ebcdic,        552 ],
      :call_entered_timestamp      => [  553, :ebcdic,          4 ],
      :call_entered_by_center      => [  554, :binary_center,   2 ],
      :call_dispatched_by_center   => [  555, :binary_center,   2 ],
      :next_dispatch_timestamp     => [  556, :ebcdic,          4 ],
      :last_response_time          => [  557, :ebcdic,          2 ],
      :accumulated_online_time     => [  558, :ebcdic,          2 ],
      :online_start_timestamp      => [  559, :ebcdic,          4 ],
      :two_assisting_specialists   => [  560, :ebcdic,         24 ],
      :call_control_flag_2         => [  561, :ebcdic,          1 ],
      :service_given_code          => [  562, :ebcdic,          2 ],
      :acc_time_before_contact     => [  563, :ebcdic,          2 ],
      :exception_process           => [  564, :ebcdic,          1 ],
      :support_center_binary       => [  565, :binary_center,   2 ],
      :site                        => [  566, :ebcdic,          1 ],
      :alt_level_1_dispatch        => [  567, :ebcdic,          3 ],
      :original_time_on_queue      => [  568, :ebcdic,          4 ],
      :problem_open_date           => [  569, :ebcdic,          4 ],
      :call_requeue_timestamp      => [  570, :ebcdic,          4 ],
      :call_requeue_center         => [  571, :binary_center,   2 ],
      :number_code_1_requeues      => [  572, :ebcdic,          1 ],
      :original_response_time      => [  573, :ebcdic,          2 ],
      :last_requeue_code           => [  574, :ebcdic,          1 ],
      :machine_type_model          => [  575, :ebcdic,         10 ],
      :call_dispatch_timestamp     => [  576, :ebcdic,          4 ],
      :log_comments                => [  577, :ebcdic,         18 ],
      :call_class                  => [  578, :ebcdic,          1 ],
      :call_disposition            => [  579, :ebcdic,          1 ],
      :data_bank_use_code          => [  580, :ebcdic,          1 ],
      :data_link_use_code          => [  581, :ebcdic,          1 ],
      :region_of_call_origin       => [  582, :ebcdic,          2 ],
      :call_survey_code            => [  583, :ebcdic,          4 ],
      :call_bypass_list            => [  584, :ebcdic,         19 ],
      :secondary_login             => [  586, :upper_ebcdic,    6 ],
      :profile_exceptions_message  => [  596, :ebcdic,         64 ],
      :new_excessive_calls         => [  597, :ebcdic,          1 ],
      :new_excessive_problems      => [  598, :ebcdic,          1 ],
      :profile_call_branch_office  => [  599, :ebcdic,          8 ],
      :profile_customer_attr_1     => [  600, :ebcdic,          8 ],
      :profile_customer_attr_2     => [  601, :ebcdic,          8 ],
      :profile_customer_attr_3     => [  602, :ebcdic,          8 ],
      :customer_time_zone_adj      => [  603, :ebcdic,          2 ],
      :time_zone_code              => [  604, :ebcdic,          2 ],
      :caller_type                 => [  605, :ebcdic,          1 ],
      :time_on_queue               => [  606, :ebcdic,          4 ],
      :call_entry_accrued_time     => [  607, :ebcdic,          1 ],
      :elapsed_time_call_worked    => [  608, :ebcdic,          4 ],
      :elapsed_assist_time         => [  609, :ebcdic,          4 ],
      :problem_status_code         => [  610, :ebcdic,          6 ],
      :support_cntr_rep_territory  => [  611, :ebcdic,          3 ],
      :region_number_watermark     => [  612, :ebcdic,          2 ],
      :device_type                 => [  615, :ebcdic,          4 ],
      :device_model                => [  616, :ebcdic,          3 ],
      :device_serial_field         => [  617, :ebcdic,          7 ],
      :target_date                 => [  618, :ebcdic,          8 ],
      :engineering_change          => [  619, :ebcdic,          9 ],
      :network_area                => [  620, :ebcdic,          2 ],
      :world_trade_region_number   => [  621, :ebcdic,          2 ],
      :offline_hours_worked        => [  622, :ebcdic,          2 ],
      :physical_assist_time        => [  623, :ebcdic,          4 ],
      :system_problem              => [  626, :ebcdic,          2 ],
      :rams_cad_key                => [  627, :ebcdic,         22 ],
      :rams_cad_flags              => [  628, :ebcdic,          1 ],
      :number_of_private_pages     => [  633, :ebcdic,          1 ],
      :branch_watermark            => [  636, :ebcdic,          3 ],
      :area_watermark              => [  640, :ebcdic,          2 ],
      :business_unit_watermark     => [  643, :ebcdic,          3 ],
      :creation_date               => [  646, :ebcdic,          9 ],
      :creation_time               => [  647, :ebcdic,          5 ],
      :alteration_date             => [  648, :ebcdic,          9 ],
      :alteration_time             => [  649, :ebcdic,          5 ],
      :apar_number                 => [  650, :ebcdic,          7 ],
      :current_text_start          => [  651, :ebcdic,          1 ],
      :follow_up_info              => [  652, :ebcdic,         12 ],
      :severity                    => [  657, :ebcdic,          1 ],
      :call_search_result          => [  658, :ebcdic,          0 ],
      :sec_call_symbol_1           => [  660, :ebcdic,         12 ],
      :sec_call_symbol_2           => [  661, :ebcdic,         12 ],
      :sec_call_symbol_3           => [  662, :ebcdic,         12 ],
      :special_option_1            => [  663, :ebcdic,          3 ],
      :special_option_2            => [  664, :ebcdic,          3 ],
      :special_option_3            => [  665, :ebcdic,          3 ],
      :special_option_4            => [  666, :ebcdic,          3 ],
      :special_option_5            => [  667, :ebcdic,          3 ],
      :network_number              => [  668, :ebcdic,          9 ],
      :special_option_6            => [  669, :ebcdic,          3 ],
      :special_option_7            => [  670, :ebcdic,          3 ],
      :genesis_id                  => [  671, :ebcdic,          3 ],
      :controlled_flag             => [  672, :ebcdic,          1 ],
      :traced_product              => [  674, :ebcdic,          1 ],
      :hardware_severity           => [  677, :ebcdic,          1 ],
      :dl_log                      => [  678, :ebcdic,          5 ],
      :dl_log_2                    => [  679, :ebcdic,          5 ],
      :problem_record_flags        => [  680, :ebcdic,          1 ],
      :special_offering_flags      => [  681, :ebcdic,          1 ],
      :problem_record_flags_2      => [  682, :ebcdic,          1 ],
      :previous_severity           => [  683, :ebcdic,          1 ],
      :original_severity           => [  684, :ebcdic,          1 ],
      :country_number              => [  685, :ebcdic,        685 ],
      :branch_office               => [  686, :ebcdic,        686 ],
      :country_watermark           => [  687, :ebcdic,          3 ],
      :next_queue                  => [  692, :ebcdic,          6 ],
      :next_center                 => [  693, :ebcdic,          3 ],
      :extra_flag                  => [  694, :ebcdic,          1 ],
      :serial_number_watermark     => [  696, :ebcdic,          7 ],
      :rsf_flag                    => [  698, :ebcdic,          1 ],
      :model_308x_save_area        => [  699, :ebcdic,          1 ],
      :poc_control_node            => [  701, :ebcdic,          1 ],
      :associated_data_key         => [  702, :ebcdic,          2 ],
      :associated_data_copy_list   => [  703, :ebcdic,          2 ],
      :bitstring                   => [  704, :ebcdic,          1 ],
      :problem_create_poc          => [  705, :ebcdic,          1 ],
      :call_count                  => [  706, :ebcdic,          2 ],
      :symbol_of_call_record       => [  707, :binary,         86 ],
      :purge_control_flags         => [  708, :ebcdic,          1 ],
      :last_service_code           => [  709, :ebcdic,          2 ],
      :call_problem_threshold      => [  710, :ebcdic,          2 ],
      :author_id                   => [  711, :ebcdic,          4 ],
      :signon2                     => [  712, :ebcdic,          6 ],
      :name                        => [  713, :ebcdic,         22 ],
      :absorb_support_list         => [  716, :ebcdic,         80 ],
      :telephone_number            => [  720, :ebcdic,         19 ],
      :authority_level             => [  721, :binary,          1 ],
      :psar_collector_indicator    => [  722, :ebcdic,          1 ],
      :dyalight_savings_time       => [  723, :ebcdic,          1 ],
      :app_driver_signon           => [  724, :binary,          4 ],
      :time_zone_adjustment        => [  725, :binary,          2 ],
      :user_status_information     => [  726, :int,             1 ],
      :queue_status_flag           => [  727, :int,             1 ],
      :hardware_center_mnemonic    => [  736, :ebcdic,          3 ],
      :hardware_center             => [  737, :binary_center,   2 ],
      :num_primary_list            => [  741, :int,             1 ],
      :num_secondary_list          => [  742, :int,             1 ],
      :num_absorb_list             => [  743, :int,             1 ],
      :primary_support_list        => [  744, :ebcdic,         60 ],
      :secondary_support_list      => [  745, :ebcdic,        120 ],
      :embargoed_countries         => [  878, :ebcdic,          3 ],
      :list_request                => [  879, :binary,          0 ],
      :center_mnemonic             => [  881, :ebcdic,          3 ],
      :cd_employee_number          => [  882, :ebcdic,          6 ],
      :cd_employee_name            => [  883, :ebcdic,         22 ],
      :minutes_from_gmt            => [  920, :binary,          2 ],
      :iris                        => [  930, :binary,         12 ],
      :cpu_origin                  => [  931, :ebcdic,          2 ],
      :processor_serial_number     => [  932, :ebcdic,          5 ],
      :psar_start_date             => [ 1074, :ebcdic,          8 ],
      :psar_end_date               => [ 1075, :ebcdic,          8 ],
      :psar_record_id              => [ 1079, :ebcdic,          1 ],
      :psar_cia                    => [ 1080, :ebcdic,          1 ],
      :psar_impact                 => [ 1081, :ebcdic,          1 ],
      :psar_action_code            => [ 1083, :ebcdic,          2 ],
      :ipar_action                 => [ 1084, :ebcdic,          1 ],
      :ipar_action_code            => [ 1085, :ebcdic,          1 ],
      :psar_site                   => [ 1086, :ebcdic,          1 ],
      :psar_system_date            => [ 1087, :ebcdic,          6 ],
      :psar_cause                  => [ 1088, :ebcdic,          2 ],
      :psar_stop_date_year         => [ 1089, :ebcdic,          2 ],
      :psar_activity_date          => [ 1090, :ebcdic,          4 ],
      :psar_fesn                   => [ 1091, :ebcdic,          7 ],
      :psar_service_code           => [ 1092, :ebcdic,          2 ],
      :ipar_mes                    => [ 1094, :ebcdic,          6 ],
      :ipar_course                 => [ 1096, :ebcdic,          5 ],
      :psar_fesn_release           => [ 1097, :ebcdic,          3 ],
      :psar_apar                   => [ 1098, :ebcdic,          5 ],
      :psar_solution               => [ 1100, :ebcdic,          1 ],
      :psar_location               => [ 1101, :ebcdic,          3 ],
      :psar_territory              => [ 1102, :ebcdic,          3 ],
      :psar_optional_data          => [ 1103, :ebcdic,          2 ],
      :psar_survey                 => [ 1104, :ebcdic,          1 ],
      :psar_special_activity       => [ 1105, :ebcdic,          1 ],
      :psar_other_office           => [ 1106, :ebcdic,          3 ],
      :psar_overtime_indicator     => [ 1107, :ebcdic,          1 ],
      :psar_support_level          => [ 1108, :ebcdic,          1 ],
      :psar_travel_time            => [ 1109, :ebcdic,          2 ],
      :psar_mileage                => [ 1110, :ebcdic,          3 ],
      :psar_expense                => [ 1111, :ebcdic,          4 ],
      :psar_activity_stop_time     => [ 1112, :ebcdic,          3 ],
      :psar_actual_time            => [ 1113, :ebcdic,          3 ],
      :psar_call_received_time     => [ 1114, :ebcdic,          3 ],
      :psar_users_time_zone_adj    => [ 1115, :ebcdic,          2 ],
      :psar_unique_sequence        => [ 1116, :ebcdic,         12 ],
      :psar_alphabetic_id          => [ 1117, :ebcdic,          1 ],
      :psar_julian                 => [ 1118, :ebcdic,          3 ],
      :ipar_technical_activity     => [ 1119, :ebcdic,          3 ],
      :psar_sequence_number        => [ 1120, :ebcdic,          5 ],
      :psar_mailed_flag            => [ 1121, :ebcdic,          1 ],
      :psar_apar_number            => [ 1122, :ebcdic,          7 ],
      :psar_user_country           => [ 1123, :ebcdic,          3 ],
      :psar_user_branch            => [ 1124, :ebcdic,          3 ],
      :psar_user_shift             => [ 1125, :ebcdic,          3 ],
      :psar_user_shift_stop        => [ 1126, :ebcdic,          3 ],
      :psar_bill_control           => [ 1127, :ebcdic,          4 ],
      :psar_mabo                   => [ 1128, :ebcdic,          4 ],
      :psar_customer_number        => [ 1129, :ebcdic,          7 ],
      :h_or_s                      => [ 1135, :upper_ebcdic,    1 ],
      :special_conditions          => [ 1137, :ebcdic,        128 ],
      :signon                      => [ 1236, :upper_ebcdic,    6 ],
      :password                    => [ 1237, :upper_ebcdic,    8 ],
      :scratch_pad_signature       => [ 1238, :ebcdic,         72 ],
      :scratch_pad_line_1          => [ 1239, :ebcdic,         72 ],
      :scratch_pad_line_2          => [ 1240, :ebcdic,         72 ],
      :scratch_pad_line_3          => [ 1241, :ebcdic,         72 ],
      :problem_type_code           => [ 1242, :ebcdic,          1 ],
      :alternate_location          => [ 1243, :ebcdic,          3 ],
      :action_code                 => [ 1244, :ebcdic,          1 ],
      :action_code_2               => [ 1245, :ebcdic,          1 ],
      :askq_item_number            => [ 1246, :ebcdic,          5 ],
      :action_code_entered         => [ 1247, :ebcdic,          2 ],
      :survey_code                 => [ 1248, :ebcdic,          2 ],
      :askq_status_flag            => [ 1249, :ebcdic,          1 ],
      :division                    => [ 1250, :ebcdic,          2 ],
      :askq_country_watermark      => [ 1251, :ebcdic,          9 ],
      :user_binary_id              => [ 1252, :ebcdic,          4 ],
      :group_request               => [ 1253, :binary,          0 ],
      :sub_function_control        => [ 1254, :ebcdic,          1 ],
      :xcel_contract_number        => [ 1255, :ebcdic,          8 ],
      :flag_byte                   => [ 1256, :ebcdic,          1 ],
      :psar_flag_byte              => [ 1258, :ebcdic,          1 ],
      :psar_problem_open_moc       => [ 1259, :ebcdic,          4 ],
      :psar_chargeable_src_ind     => [ 1260, :ebcdic,          1 ],
      :global_enterprise_number    => [ 1261, :ebcdic,         10 ],
      :seven_special_options       => [ 1262, :ebcdic,         28 ],
      :nls_street_address          => [ 1263, :nls,            19 ],
      :chargeable_queue_name       => [ 1264, :ebcdic,          6 ],
      :nls_city                    => [ 1265, :nls,            10 ],
      :city_expansion              => [ 1266, :ebcdic,         10 ],
      :nls_state                   => [ 1267, :nls,             4 ],
      :zip_code                    => [ 1268, :ebcdic,          9 ],
      :chargeable_center           => [ 1269, :ebcdic,          3 ],
      :external_system_problem     => [ 1270, :ebcdic,          7 ],
      :external_system_country     => [ 1271, :ebcdic,          3 ],
      :iin_account_code            => [ 1272, :ebcdic,          8 ],
      :last_alter_timestamp        => [ 1273, :ebcdic,          6 ],
      :psear_chargeable_time       => [ 1275, :ebcdic,          2 ],
      :psar_chargeable_after_hours => [ 1276, :ebcdic,          2 ],
      :psar_remote_write           => [ 1278, :ebcdic,          1 ],
      :psar_file_and_symbol        => [ 1279, :ebcdic,         16 ],
      :nls_family_abstract         => [ 1312, :nls,            53 ],
      :error_message               => [ 1384, :ebcdic,         79 ],
      :information_text_lines      => [ 1390, :text_lines,     72 ],
      :beginning_page_number       => [ 1391, :znumber,         3 ],
      :ending_page_number          => [ 1392, :znumber,         3 ],
      :total_pages                 => [ 1393, :ebcdic,         32 ],
      :external_problem_w_country  => [ 1550, :ebcdic,         10 ],
      :cstatus                     => [ 1633, :upper_ebcdic,    7 ],
      :problem_flag_bits           => [ 2150, :ebcdic,          1 ],
      :invalid_reason_code         => [ 2151, :ebcdic,          8 ],
      :component_id_or_device      => [ 2152, :ebcdic,         12 ],
      :onsite_prob_det_required    => [ 2153, :ebcdic,        2153 ],
      :expected_duration           => [ 2154, :ebcdic,          4 ],
      :target_arrival_time         => [ 2155, :ebcdic,         12 ],
      :m_s_branch_office           => [ 2156, :ebcdic,          3 ],
      :part_number                 => [ 2157, :ebcdic,          8 ],
      :ecco_problem                => [ 2158, :ebcdic,          7 ],
      :special_message             => [ 2159, :ebcdic,         70 ],
      :contract                    => [ 2160, :ebcdic,         11 ],
      :bid_number                  => [ 2161, :ebcdic,          8 ],
      :service_contract            => [ 2162, :ebcdic,          7 ],
      :customer_claimed_contract   => [ 2163, :ebcdic,          7 ],
      :contract_type               => [ 2164, :ebcdic,          3 ],
      :origin_id                   => [ 2165, :ebcdic,          1 ],
      :customer_problem_number     => [ 2166, :ebcdic,         10 ],
      :contract_hours              => [ 2167, :ebcdic,         24 ],
      :service_hours               => [ 2168, :ebcdic,         24 ],
      :authorized_name             => [ 2169, :ebcdic,         25 ],
      :authorized_phone_number     => [ 2170, :ebcdic,         19 ],
      :cmr_customer_number         => [ 2171, :ebcdic,          7 ],
      :iso_country_number          => [ 2208, :ebcdic,          2 ],
      :vantive_customer_id         => [ 2209, :ebcdic,          4 ],
      :vantive_email_selector      => [ 2210, :ebcdic,          4 ],
      :order_reference_number      => [ 2211, :ebcdic,         13 ],
      :part_number_entitled        => [ 2212, :ebcdic,          4 ],
      :remote_server_name          => [ 2213, :ebcdic,          6 ],
      :cpu_prefix                  => [ 2214, :ebcdic,          4 ],
      :customer_country            => [ 2216, :ebcdic,          3 ],
      :customer_number_x           => [ 2217, :ebcdic,          7 ],
      :cpu_type_x                  => [ 2218, :ebcdic,          4 ],
      :cpu_serial                  => [ 2219, :ebcdic,          7 ],
      :service_request             => [ 2221, :ebcdic,         11 ],
      :request_type                => [ 2417, :ebcdic,          3 ],
      :request_type_description    => [ 2418, :ebcdic,          8 ],
      :sub_request_type            => [ 2419, :ebcdic,          3 ],
      :sub_request_description     => [ 2420, :ebcdic,         30 ],
      :entitlement_code            => [ 2421, :ebcdic,          4 ],
      :contract_number             => [ 2422, :ebcdic,         20 ],
      :pid_number                  => [ 2423, :ebcdic,          7 ],
      :keyword_three               => [ 2424, :ebcdic,         15 ],
      :resolver_name               => [ 2496, :ebcdic,         22 ],
      :problem_e_mail              => [ 2497, :ebcdic,         64 ],
      :resolver_id                 => [ 2509, :ebcdic,          6 ]
    }
    
    def initialize(fetch_fields = nil)
      @logger = RAILS_DEFAULT_LOGGER
      @fetch_fields = fetch_fields
      @fields = Hash.new
    end
    
    # Convert each of the entries from the table above into a
    # constant.  These might not be used any more...
    #
    # Also create @@field_num_to_name and @@field_num_to_cvt.  These
    # might not get used either.
    #
    @@field_num_to_name   = Array.new
    @@field_num_to_cvt    = Array.new
    @@field_num_to_width  = Array.new
    
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      const_set(k.to_s.upcase, index)
      @@field_num_to_name[index] = k
      @@field_num_to_cvt[index] =  convert
      @@field_num_to_width[index] = width
    end

    def self.sym_to_index(sym)
      FIELD_DEFINITIONS[sym][0]
    end

    def self.index_to_sym(index)
      @@field_num_to_name[index]
    end
    
    #
    # Create field getters and setters
    #
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      eval "def #{k}; reader(#{index}, :#{convert}, #{width}); end", nil, __FILE__, __LINE__
      eval "def #{k}?; has_key?(#{index}); end", nil, __FILE__, __LINE__
      eval "def #{k}=(data); writer(#{index}, :#{convert}, #{width}, data); end", nil, __FILE__, __LINE__
    end

    def dump_fields
      @fields.each_pair do |k, v|
        @logger.debug("DEBUG: field:#{k} is #{v.value}")
      end
    end

    def delete(index)
      @fields.delete(index_or_sym_to_index(index))
    end

    def merge(new_fields)
      self.dup.merge!(new_fields)
    end
    
    def merge!(new_fields)
      if new_fields.is_a?(Retain::Fields)
        merge_fields!(new_fields)
      else
        merge_hash!(new_fields)
      end
      self
    end
    
    def has_key?(index)
      @fields.has_key?(index_or_sym_to_index(index))
    end
    
    def [](index)
      @fields[index_or_sym_to_index(index)]
    end

    #
    # Used to set values received from retain into a field
    #
    def add_raw(index, value)
      index = index_or_sym_to_index(index)
      cvt = @@field_num_to_cvt[index]
      width = @@field_num_to_width[index]
      if @fields.has_key?(index)
        field = @fields[index]
        tmp = field.raw_value
        if tmp.is_a?(Array)
          tmp << value
        else
          tmp = [ tmp, value ]
        end
        @fields[index].raw_value = tmp
      else
        @fields[index] = Field.new(cvt, width, value, true)
      end
    end

    def []=(index, value)
      index = index_or_sym_to_index(index)
      cvt = @@field_num_to_cvt[index]
      width = @@field_num_to_width[index]
      @fields[index] = Field.new(cvt, width, value)
    end
    
    def each_pair
      @fields.each_pair do |k, v|
        yield(k, v.value)
      end
    end
    
    def each_raw_pair
      @fields.each_pair do |k, v|
        yield(k, v)
      end
    end
    
    def to_debug
      r = ''
      @fields.each_pair do |k, v|
        r << "DEBUG: #{@@field_num_to_name[k]}: '#{v.value}'\n"
      end
      r
    end

    private

    def merge_fields!(new_fields)
      new_fields.each_raw_pair do |k, v|
        index = index_or_sym_to_index(k)
        if false
          if v.is_a?(Array)
            @logger.debug("DEBUG: merge hash #{index}:Array")
          else
            @logger.debug("DEBUG: merge hash #{index}:#{v.value}")
          end
        end
        @fields[index] = v
      end
    end
    
    def merge_hash!(new_fields)
      new_fields.each_pair do |k, v|
        index = index_or_sym_to_index(k)
        cvt = @@field_num_to_cvt[index]
        width = @@field_num_to_width[index]
        if false
          if v.is_a?(Array)
            @logger.debug("DEBUG: merge hash #{index}:Array")
          else
            @logger.debug("DEBUG: merge hash #{index}:#{v}")
          end
        end
        @fields[index] = Field.new(cvt, width, v)
      end
    end
    
    def index_or_sym_to_index(index)
      if index.is_a?(Symbol)
        Fields.sym_to_index(index)
      else
        index
      end
    end
    
    #
    # If the attribute or field is already present, then just return
    # it.  Otherwise, if the fields have not been fetched and
    # @fetch_fields is set up so we can fetch them, we call sendit via
    # @fetch_fields.  If it returns an error, we process it
    # appropriately.  Otherwise, we set @fetched to true so we do not
    # try to fetch the fields again and we check to see if the field
    # we were originally trying to get was returned.  If it is, we
    # return its value.  If all this fails, we raise an exception.
    #
    def reader(index, cvt, width)
      if f = @fields[index]
        return f.value
      elsif not (@fetched || @fetch_fields.nil?)
        base_obj = @fetch_fields.call
        unless base_obj.rc == 0
          if base_obj.error_message?
            msg = base_obj.error_message + ( " error=%d" % base_obj.rc )
            raise msg
          else
            raise Errors[base_obj.rc]
          end
        end
        @fetched = true
        if f = @fields[index]
          return f.value
        end
      end
      raise "reader did not read attribute"
    end
    
    def writer(index, cvt, width, value)
      @fields[index] = Field.new(cvt, width, value)
    end
  end
end
