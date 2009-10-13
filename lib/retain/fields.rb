#
# Right now, the Fields class is just a place to put constants that
# mnemonically map to the data element fields.

require 'retain/utils'

module Retain
  class Fields
    cattr_accessor :logger

    #
    # A hash used to create the getters and setters in request and
    # reply.  Also used to create upper case constant equivalents.
    #
    FIELD_DEFINITIONS = {
      :area_number                 => [    1, :ebcdic,              2 ],
      :branch                      => [    2, :upper_ebcdic,        3 ],
      :country                     => [    3, :upper_ebcdic,        3 ],
      :problem                     => [    4, :upper_ebcdic,        5 ],
      :title_format_id             => [   10, :ebcdic,              4 ],
      :customer_number             => [   11, :upper_ebcdic,        7 ],
      :hit_count                   => [   11, :int,                 4 ],
      :customer_name               => [   14, :ebcdic,             28 ],
      :customer_contact_name       => [   19, :ebcdic,             28 ],
      :cpu_type                    => [   22, :ebcdic,              4 ],
      :priority                    => [   23, :znumber,             1 ],
      :queue_name                  => [   27, :ebcdic_strip,        6 ],
      :de32                        => [   32, :binary,              0 ],
      :cpu_serial_number           => [   39, :ebcdic,              7 ],
      :component_id                => [   40, :ebcdic,             12 ],
      :center                      => [   41, :ebcdic_strip,        3 ],
      :comment                     => [   42, :ebcdic,             54 ],
      :business_unit               => [   48, :ebcdic,              3 ],
      :queue_level                 => [   54, :ebcdic,              1 ],
      :apar_abstract               => [   72, :ebcdic,             68 ],
      :routing_id                  => [   77, :ebcdic,             11 ],
      :support_level               => [   78, :ebcdic,              1 ],
      :support_level               => [   78, :ebcdic,              1 ],
      :security_classification     => [   79, :ebcdic,              1 ],
      :creator_serial              => [   87, :binary,              9 ],
      :q_or_d                      => [   89, :ebcdic,              1 ],
      :nls_creator_name            => [   97, :nls,                30 ],
      :nls_customer_name           => [  101, :nls,                30 ],
      :nls_contact_name            => [  102, :nls,                30 ],
      :nls_scratch_pad_1           => [  103, :nls_text_lines,     74 ],
      :nls_scratch_pad_2           => [  104, :nls_text_lines,     74 ],
      :nls_scratch_pad_3           => [  105, :nls_text_lines,     74 ],
      :nls_scratch_pad_signature   => [  106, :nls_text_lines,     74 ],
      :nls_text_line               => [  107, :nls_text_lines,     74 ],
      :responder_notification_flag => [  108, :ebcdic_y_or_n,       1 ],
      :nls_user_keyword            => [  118, :ebcdic,             16 ],
      :assignee                    => [  119, :ebcdic,              9 ],
      :nominate_flag               => [  121, :ebcdic,              1 ],
      :send_askq_reply             => [  127, :ebcdic_y_or_n,       1 ],
      :nls_comment                 => [  128, :nls,                56 ],
      :return_data_indicator       => [  130, :ebcdic_y_or_n,       1 ],
      :author_type                 => [  131, :ebcdic,              1 ],
      :owning_retain_node          => [  132, :ebcdic,              3 ],
      :nls_pmr_owner_name          => [  133, :nls,                24 ],
      :pmr_owner_phone             => [  134, :ebcdic,             19 ],
      :pmr_owner_id                => [  135, :ebcdic,              6 ],
      :pmr_owner_territory         => [  136, :ebcdic,              3 ],
      :pmr_owner_name              => [  141, :ebcdic,             22 ],
      :sec_1_queue                 => [  186, :ebcdic_strip,        6 ],
      :sec_1_center                => [  187, :ebcdic_strip,        3 ],
      :sec_1_ppg                   => [  188, :ppg,                 2 ],
      :sec_1_h_or_s                => [  189, :upper_ebcdic,        1 ],
      :sec_2_queue                 => [  190, :ebcdic_strip,        6 ],
      :sec_2_center                => [  191, :ebcdic_strip,        3 ],
      :sec_2_ppg                   => [  192, :ppg,                 2 ],
      :sec_2_h_or_s                => [  193, :upper_ebcdic,        1 ],
      :sec_3_queue                 => [  194, :ebcdic_strip,        6 ],
      :sec_3_center                => [  195, :ebcdic_strip,        3 ],
      :sec_3_ppg                   => [  196, :ppg,                 2 ],
      :sec_3_h_or_s                => [  197, :upper_ebcdic,        1 ],
      :user_assigned_problem_flag  => [  206, :ebcdic,              1 ],
      :family_offering             => [  226, :ebcdic,             12 ],
      :ret_sys_inserted_flag       => [  232, :ebcdic,              1 ],
      :ret_sys_text_and_signature  => [  233, :ebcdic,              1 ],
      :return_signature_line_tail  => [  234, :ebcdic,              1 ],
      :change_sig_line_name_flag   => [  235, :ebcdic,              1 ],
      :premium_response            => [  249, :ebcdic,              1 ],
      :severity_changeable         => [  250, :ebcdic,              1 ],
      :voice_response_entitled     => [  251, :ebcdic,              1 ],
      :support_center_country      => [  256, :ebcdic,              3 ],
      :routing_id                  => [  257, :ebcdic,             11 ],
      :release                     => [  258, :ebcdic,              3 ],
      :category                    => [  259, :ebcdic,              3 ],
      :system_tape                 => [  260, :ebcdic,              4 ],
      :component_tape              => [  261, :ebcdic,              4 ],
      :environment                 => [  262, :ebcdic,             18 ],
      :branch_and_country          => [  273, :ebcdic,              6 ],
      :territory                   => [  274, :ebcdic,            274 ],
      :previous_center             => [  275, :ebcdic,              3 ],
      :previous_queue              => [  276, :ebcdic_strip,        6 ],
      :previous_priority           => [  277, :ebcdic,              1 ],
      :previous_level              => [  278, :ebcdic,              1 ],
      :previous_category           => [  279, :ebcdic,              3 ],
      :call_complete_code          => [  280, :ebcdic,              1 ],
      :alarm_time                  => [  282, :ebcdic,              2 ],
      :system_down                 => [  284, :ebcdic_y_or_n,       1 ],
      :call_back_time              => [  285, :ebcdic,              1 ],
      :entered_by_center           => [  292, :ebcdic,              3 ],
      :entered_by_employee         => [  293, :ebcdic,              6 ],
      :p_s_b                       => [  298, :upper_ebcdic,        1 ],
      :dispatched_by_center        => [  301, :ebcdic,              3 ],
      :requeue_center              => [  305, :ebcdic,              3 ],
      :requeue_employee            => [  306, :ebcdic,              6 ],
      :call_symbol                 => [  316, :binary,             12 ],
      :addtxt_line                 => [  331, :text_lines,         72 ],
      :customer_account            => [  332, :ebcdic,            332 ],
      :dcsf_user_id                => [  333, :ebcdic,            333 ],
      :dcsf_node_id                => [  334, :ebcdic,              8 ],
      :user_id                     => [  335, :ebcdic,            335 ],
      :customer_problem            => [  336, :ebcdic,             14 ],
      :voice_contact_required      => [  339, :ebcdic,              1 ],
      :alterable_format_line       => [  340, :text_lines,         72 ],
      :formatted_panel_area        => [  341, :ebcdic,             20 ],
      :corporate_entity            => [  510, :ebcdic,            510 ],
      :director_number             => [  524, :ebcdic,              4 ],
      :dispatched_employee         => [  525, :ebcdic,              6 ],
      :pre_assigned_employee       => [  526, :ebcdic,              6 ],
      :requested_element           => [  528, :binary,              0 ],
      :call_queue_status_flag      => [  536, :ebcdic,              1 ],
      :contact_phone_1             => [  537, :ebcdic,             19 ],
      :contact_phone_2             => [  538, :ebcdic,             19 ],
      :fup_control_count           => [  539, :ebcdic,              1 ],
      :askq_control_flag           => [  540, :ebcdic,              1 ],
      :special_application         => [  541, :ebcdic,              1 ],
      :hardware_territory          => [  542, :ebcdic,              3 ],
      :call_control_flag_1         => [  543, :byte,                1 ],
      :call_queue_status_flag      => [  544, :ebcdic,              1 ],
      :original_queue              => [  545, :ebcdic_strip,        6 ],
      :original_level              => [  546, :ebcdic,              1 ],
      :original_center             => [  547, :ebcdic_strip,        3 ],
      :original_category           => [  548, :ebcdic,              3 ],
      :original_priority           => [  549, :ebcdic,              1 ],
      :ppg                         => [  550, :ppg,                 2 ],
      :comp_id_or_alias            => [  551, :ebcdic,             12 ],
      :pmr_status_watermark        => [  552, :ebcdic,            552 ],
      :call_entered_timestamp      => [  553, :ebcdic,              4 ], # date/time
      :call_entered_by_center      => [  554, :binary_center,       2 ],
      :call_dispatched_by_center   => [  555, :binary_center,       2 ],
      :next_dispatch_timestamp     => [  556, :ebcdic,              4 ], # date/time
      :last_response_time          => [  557, :ebcdic,              2 ], # time
      :accumulated_online_time     => [  558, :ebcdic,              2 ], # time
      :online_start_timestamp      => [  559, :ebcdic,              4 ], # date/time
      :two_assisting_specialist    => [  560, :ebcdic,             24 ],
      :call_control_flag_2         => [  561, :ebcdic,              1 ],
      :service_given               => [  562, :ebcdic,              2 ],
      :acc_time_before_contact     => [  563, :ebcdic,              2 ], # time
      :exception_process           => [  564, :ebcdic,              1 ],
      :software_center             => [  565, :binary_center,       2 ],
      :site                        => [  566, :ebcdic,              1 ], # hex
      :alt_level_1_dispatch        => [  567, :ebcdic,              3 ],
      :original_time_on_queue      => [  568, :ebcdic,              4 ], # date/time I guess
      :problem_open_date           => [  569, :ebcdic,              4 ],
      :call_requeue_timestamp      => [  570, :ebcdic,              4 ], # date/time
      :call_requeue_center         => [  571, :binary_center,       2 ],
      :number_code_1_requeue       => [  572, :ebcdic,              1 ], # hex
      :original_response_time      => [  573, :ebcdic,              2 ], # time
      :last_requeue_code           => [  574, :ebcdic,              1 ],
      :machine_type_model          => [  575, :ebcdic,             10 ],
      :call_dispatch_timestamp     => [  576, :ebcdic,              4 ], # date/time
      :log_comment                 => [  577, :ebcdic,             18 ],
      :call_class                  => [  578, :ebcdic,              1 ],
      :call_disposition            => [  579, :ebcdic,              1 ],
      :data_bank_use_code          => [  580, :ebcdic,              1 ],
      :data_link_use_code          => [  581, :ebcdic,              1 ],
      :region_of_call_origin       => [  582, :ebcdic,              2 ],
      :call_survey_code            => [  583, :ebcdic,              4 ],
      :call_bypass_list            => [  584, :ebcdic,             19 ],
      :operand                     => [  585, :upper_ebcdic,        4 ],
      :secondary_login             => [  586, :upper_ebcdic,        6 ],
      :target_queue                => [  587, :ebcdic_strip,        6 ],
      :target_center               => [  588, :ebcdic_strip,        3 ],
      :profile_exceptions_message  => [  596, :ebcdic,             64 ],
      :new_excessive_call          => [  597, :ebcdic,              1 ],
      :new_excessive_problem       => [  598, :ebcdic,              1 ],
      :profile_call_branch_office  => [  599, :ebcdic,              8 ],
      :profile_customer_attr_1     => [  600, :ebcdic,              8 ],
      :profile_customer_attr_2     => [  601, :ebcdic,              8 ],
      :profile_customer_attr_3     => [  602, :ebcdic,              8 ],
      :customer_time_zone_adj      => [  603, :short,               2 ], # hex
      :time_zone_code              => [  604, :short,               2 ],
      :caller_type                 => [  605, :ebcdic,              1 ],
      :time_on_queue               => [  606, :ebcdic,              4 ], # date/time?
      :call_entry_accrued_time     => [  607, :ebcdic,              1 ],
      :elapsed_time_call_worked    => [  608, :ebcdic,              4 ], # date/time?
      :elapsed_assist_time         => [  609, :ebcdic,              4 ], # date/time?
      :problem_status_code         => [  610, :ebcdic,              6 ],
      :support_cntr_rep_territory  => [  611, :ebcdic,              3 ],
      :region_number_watermark     => [  612, :ebcdic,              2 ],
      :device_type                 => [  615, :ebcdic,              4 ],
      :device_model                => [  616, :ebcdic,              3 ],
      :device_serial_field         => [  617, :ebcdic,              7 ],
      :target_date                 => [  618, :ebcdic,              8 ],
      :engineering_change          => [  619, :ebcdic,              9 ],
      :network_area                => [  620, :ebcdic,              2 ],
      :world_trade_region_number   => [  621, :ebcdic,              2 ],
      :offline_hours_worked        => [  622, :ebcdic,              2 ], # time
      :physical_assist_time        => [  623, :ebcdic,              4 ],
      :system_problem              => [  626, :ebcdic,              2 ], # time
      :rams_cad_key                => [  627, :ebcdic,             22 ],
      :rams_cad_flag               => [  628, :ebcdic,              1 ],
      :format_panel_number         => [  630, :ebcdic,              4 ],
      :format_panel                => [  631, :format_panel_lines, 80 ],
      :panel_operand               => [  632, :ebcdic,              1 ],
      :number_of_private_page      => [  633, :ebcdic,              1 ],
      :extra_bit                   => [  634, :ebcdic,              1 ],
      :country_watermark           => [  635, :ebcdic,              3 ],
      :branch_watermark            => [  636, :ebcdic,              3 ],
      :country_number_watermark    => [  639, :ebcdic,              3 ],
      :area_watermark              => [  640, :ebcdic,              2 ],
      :business_unit_watermark     => [  643, :ebcdic,              3 ],
      :creation_date               => [  646, :ebcdic,              9 ],
      :creation_time               => [  647, :ebcdic,              5 ],
      :alteration_date             => [  648, :ebcdic,              9 ],
      :alteration_time             => [  649, :ebcdic,              5 ],
      :apar_number                 => [  650, :ebcdic,              7 ],
      :current_text_start          => [  651, :ebcdic,              1 ],
      :follow_up_info              => [  652, :ebcdic,             12 ],
      :severity                    => [  657, :znumber,             1 ],
      :call_search_result          => [  658, :binary,             86 ],
      :sec_call_symbol_1           => [  660, :ebcdic,             12 ],
      :sec_call_symbol_2           => [  661, :ebcdic,             12 ],
      :sec_call_symbol_3           => [  662, :ebcdic,             12 ],
      :special_option_1            => [  663, :ebcdic,              3 ],
      :special_option_2            => [  664, :ebcdic,              3 ],
      :special_option_3            => [  665, :ebcdic,              3 ],
      :special_option_4            => [  666, :ebcdic,              3 ],
      :special_option_5            => [  667, :ebcdic,              3 ],
      :network_number              => [  668, :ebcdic,              9 ],
      :special_option_6            => [  669, :ebcdic,              3 ],
      :special_option_7            => [  670, :ebcdic,              3 ],
      :genesis_id                  => [  671, :ebcdic,              3 ],
      :controlled_flag             => [  672, :ebcdic,              1 ],
      :traced_product              => [  674, :ebcdic,              1 ],
      :hardware_severity           => [  677, :ebcdic,              1 ],
      :dl_log                      => [  678, :ebcdic,              5 ],
      :dl_log_2                    => [  679, :ebcdic,              5 ],
      :problem_record_flag         => [  680, :ebcdic,              1 ],
      :special_offering_flag       => [  681, :ebcdic,              1 ],
      :problem_record_flags_2      => [  682, :ebcdic,              1 ],
      :previous_severity           => [  683, :ebcdic,              1 ],
      :original_severity           => [  684, :ebcdic,              1 ],
      :country_number              => [  685, :ebcdic,            685 ],
      :branch_office               => [  686, :ebcdic,            686 ],
      :country_watermark           => [  687, :ebcdic,              3 ],
      :next_queue                  => [  692, :ebcdic_strip,        6 ],
      :next_center                 => [  693, :ebcdic_strip,        3 ],
      :extra_flag                  => [  694, :ebcdic,              1 ],
      :serial_number_watermark     => [  696, :ebcdic,              7 ],
      :rsf_flag                    => [  698, :ebcdic,              1 ],
      :model_308x_save_area        => [  699, :ebcdic,              1 ],
      :poc_control_node            => [  701, :ebcdic,              1 ],
      :associated_data_key         => [  702, :ebcdic,              2 ],
      :associated_data_copy_list   => [  703, :ebcdic,              2 ],
      :bitstring                   => [  704, :ebcdic,              1 ],
      :problem_create_poc          => [  705, :ebcdic,              1 ],
      :call_count                  => [  706, :ebcdic,              2 ],
      :symbol_of_call_record       => [  707, :binary,             86 ],
      :purge_control_flag          => [  708, :ebcdic,              1 ],
      :last_service_code           => [  709, :ebcdic,              2 ],
      :call_problem_threshold      => [  710, :ebcdic,              2 ],
      :author_id                   => [  711, :ebcdic,              4 ],
      :signon2                     => [  712, :ebcdic,              6 ],
      :name                        => [  713, :ebcdic,             22 ],
      :absorb_support_list         => [  716, :ebcdic,             80 ],
      :telephone_number            => [  720, :ebcdic,             19 ],
      :authority_level             => [  721, :binary,              1 ],
      :psar_collector_indicator    => [  722, :ebcdic,              1 ],
      :daylight_savings_time       => [  723, :ebcdic_y_or_n,       1 ],
      :app_driver_signon           => [  724, :binary,              4 ],
      :time_zone_adjustment        => [  725, :short,               2 ],
      :user_status_information     => [  726, :int,                 1 ],
      :queue_status_flag           => [  727, :int,                 1 ],
      :hardware_center_mnemonic    => [  736, :ebcdic,              3 ],
      :hardware_center             => [  737, :binary_center,       2 ],
      :psar_number                 => [  738, :ebcdic,              6 ],
      :num_primary_list            => [  741, :int,                 1 ],
      :num_secondary_list          => [  742, :int,                 1 ],
      :num_absorb_list             => [  743, :int,                 1 ],
      :primary_support_list        => [  744, :ebcdic,             60 ],
      :secondary_support_list      => [  745, :ebcdic,            120 ],
      :company_name                => [  757, :ebcdic,             36 ],
      :daylight_time_flag          => [  765, :ebcdic_y_or_n,       1 ],
      :time_zone                   => [  766, :ebcdic,              5 ],
      :time_zone_binary            => [  767, :short,               2 ],
      :embargoed_country           => [  878, :ebcdic,              3 ],
      :list_request                => [  879, :group,               0 ],
      :software_center_mnemonic    => [  881, :ebcdic,              3 ],
      :cd_employee_number          => [  882, :ebcdic,              6 ],
      :cd_employee_name            => [  883, :ebcdic,             22 ],
      :center_daylight_time_flag   => [  892, :ebcdic_y_or_n,       1 ],
      :delay_to_time               => [  919, :short,               2 ],
      :minutes_from_gmt            => [  920, :short,               2 ],
      :iris                        => [  930, :binary,             12 ],
      :cpu_origin                  => [  931, :ebcdic,              2 ],
      :processor_serial_number     => [  932, :ebcdic,              5 ],
      :psi_time_ht                 => [ 1033, :ebcdic,              2 ],
      :travel_overtime             => [ 1034, :ebcdic,              2 ],
      :psar_start_date             => [ 1074, :ebcdic,              8 ],
      :psar_end_date               => [ 1075, :ebcdic,              8 ],
      :stop_time                   => [ 1076, :int,                 4 ],
      :psar_record_id              => [ 1079, :ebcdic,              1 ],
      :psar_cia                    => [ 1080, :ebcdic,              1 ],
      :psar_impact                 => [ 1081, :number,              1 ],
      :psar_solution_blah          => [ 1082, :ebcdic,              1 ], # Don't use this by mistake!!
      :psar_action_code            => [ 1083, :number,              2 ],
      :ipar_action                 => [ 1084, :ebcdic,              1 ],
      :ipar_action_code            => [ 1085, :ebcdic,              1 ],
      :psar_site                   => [ 1086, :ebcdic,              1 ],
      :psar_system_date            => [ 1087, :ebcdic,              6 ],
      :psar_cause                  => [ 1088, :number,              2 ],
      :psar_stop_date_year         => [ 1089, :ebcdic,              2 ],
      :psar_activity_date          => [ 1090, :ebcdic,              4 ],
      :psar_fesn                   => [ 1091, :ebcdic,              7 ],
      :psar_service_code           => [ 1092, :number,              2 ],
      :overtime                    => [ 1093, :ebcdic,              3 ],
      :ipar_mes                    => [ 1094, :ebcdic,              6 ],
      :local_stop_date             => [ 1095, :ebcdic,              8 ],
      :ipar_course                 => [ 1096, :ebcdic,              5 ],
      :psar_fesn_release           => [ 1097, :ebcdic,              3 ],
      :psar_apar                   => [ 1098, :ebcdic,              5 ],
      :cuprimd                     => [ 1099, :ebcdic,              1 ],
      :psar_solution_code          => [ 1100, :number,              1 ],
      :psar_location               => [ 1101, :ebcdic,              3 ],
      :psar_territory              => [ 1102, :ebcdic,              3 ],
      :psar_optional_data          => [ 1103, :ebcdic,              2 ],
      :psar_survey                 => [ 1104, :ebcdic,              1 ],
      :psar_special_activity       => [ 1105, :ebcdic,              1 ],
      :psar_other_office           => [ 1106, :ebcdic,              3 ],
      :psar_overtime_indicator     => [ 1107, :ebcdic,              1 ],
      :psar_support_level          => [ 1108, :ebcdic,              1 ],
      :psar_travel_time            => [ 1109, :ebcdic,              2 ],
      :psar_mileage                => [ 1110, :ebcdic,              3 ],
      :psar_expense                => [ 1111, :ebcdic,              4 ],
      :psar_activity_stop_time     => [ 1112, :ebcdic,              3 ],
      :psar_actual_time            => [ 1113, :znumber,             3 ],
      :psar_call_received_time     => [ 1114, :ebcdic,              3 ],
      :psar_users_time_zone_adj    => [ 1115, :short,               2 ],
      :psar_unique_sequence        => [ 1116, :ebcdic,             12 ],
      :psar_alphabetic_id          => [ 1117, :ebcdic,              1 ],
      :psar_julian                 => [ 1118, :ebcdic,              3 ],
      :ipar_technical_activity     => [ 1119, :ebcdic,              3 ],
      :psar_sequence_number        => [ 1120, :ebcdic,              5 ],
      :psar_mailed_flag            => [ 1121, :ebcdic,              1 ],
      :psar_apar_number            => [ 1122, :ebcdic,              7 ],
      :psar_user_country           => [ 1123, :ebcdic,              3 ],
      :psar_user_branch            => [ 1124, :ebcdic,              3 ],
      :psar_user_shift             => [ 1125, :ebcdic,              3 ],
      :psar_user_shift_stop        => [ 1126, :ebcdic,              3 ],
      :psar_bill_control           => [ 1127, :ebcdic,              4 ],
      :psar_mabo                   => [ 1128, :ebcdic,              4 ],
      :psar_customer_number        => [ 1129, :ebcdic,              7 ],
      :h_or_s                      => [ 1135, :upper_ebcdic,        1 ],
      :special_condition           => [ 1137, :ebcdic,            128 ],
      :signon                      => [ 1236, :upper_ebcdic,        6 ],
      :password                    => [ 1237, :upper_ebcdic,        8 ],
      :scratch_pad_signature       => [ 1238, :text_lines,         72 ],
      :scratch_pad_line_1          => [ 1239, :text_lines,         72 ],
      :scratch_pad_line_2          => [ 1240, :text_lines,         72 ],
      :scratch_pad_line_3          => [ 1241, :text_lines,         72 ],
      :problem_type_code           => [ 1242, :ebcdic,              1 ],
      :alternate_location          => [ 1243, :ebcdic,              3 ],
      :action_code                 => [ 1244, :ebcdic,              1 ],
      :action_code_2               => [ 1245, :ebcdic,              1 ],
      :askq_item_number            => [ 1246, :ebcdic,              5 ],
      :action_code_entered         => [ 1247, :ebcdic,              2 ],
      :survey_code                 => [ 1248, :ebcdic,              2 ],
      :askq_status_flag            => [ 1249, :ebcdic,              1 ],
      :division                    => [ 1250, :ebcdic,              2 ],
      :askq_country_watermark      => [ 1251, :ebcdic,              9 ],
      :user_binary_id              => [ 1252, :ebcdic,              4 ],
      :group_request               => [ 1253, :group,               0 ],
      :sub_function_control        => [ 1254, :ebcdic,              1 ],
      :xcel_contract_number        => [ 1255, :ebcdic,              8 ],
      :flag_byte                   => [ 1256, :ebcdic,              1 ],
      :present_author_survey       => [ 1257, :ebcdic_y_or_n,       1 ],
      :psar_flag_byte              => [ 1258, :ebcdic,              1 ],
      :psar_problem_open_moc       => [ 1259, :ebcdic,              4 ],
      :psar_chargeable_src_ind     => [ 1260, :ebcdic,              1 ],
      :global_enterprise_number    => [ 1261, :ebcdic,             10 ],
      :seven_special_option        => [ 1262, :ebcdic,             28 ],
      :nls_street_address          => [ 1263, :nls,                19 ],
      :chargeable_queue_name       => [ 1264, :ebcdic_strip,        6 ],
      :nls_city                    => [ 1265, :nls,                10 ],
      :city_expansion              => [ 1266, :ebcdic,             10 ],
      :nls_state                   => [ 1267, :nls,                 4 ],
      :zip_code                    => [ 1268, :ebcdic,              9 ],
      :chargeable_center           => [ 1269, :ebcdic,              3 ],
      :external_system_problem     => [ 1270, :ebcdic,              7 ],
      :external_system_country     => [ 1271, :ebcdic,              3 ],
      :iin_account_code            => [ 1272, :ebcdic,              8 ],
      :last_alter_timestamp        => [ 1273, :binary,              6 ],
      :premium_flag                => [ 1274, :ebcdic,              1 ],
      :psar_chargeable_time        => [ 1275, :short,               2 ],
      :psar_chargeable_after_hour  => [ 1276, :short,               2 ],
      :psar_remote_write           => [ 1278, :ebcdic,              1 ],
      :psar_file_and_symbol        => [ 1279, :psarfs,             16 ],
      :problem_create_only         => [ 1290, :ebcdic,              1 ],
      :nls_family_abstract         => [ 1312, :nls,                53 ],
      :format_title                => [ 1319, :ebcdic,             50 ],
      :format_line_count           => [ 1320, :ebcdic,              2 ],
      :alter_create_date_sequence  => [ 1321, :ebcdic,             10 ],
      :alter_create_time           => [ 1322, :ebcdic,              5 ],
      :format_chain                => [ 1323, :ebcdic,              7 ],
      :format_line_count_binary    => [ 1324, :ebcdic,              1 ],
      :offset_to_first_input_field => [ 1325, :ebcdic,              2 ],
      :panel_keyword_table         => [ 1326, :ebcdic,             55 ],
      :error_message               => [ 1384, :ebcdic,             79 ],
      :call_received_time          => [ 1386, :short,               2 ],
      :actual_local_time           => [ 1387, :short,               2 ],
      :psi_time_hex                => [ 1388, :short,               2 ],
      :travel_time                 => [ 1389, :short,               2 ],
      :information_text_line       => [ 1390, :text_lines,         72 ],
      :beginning_page_number       => [ 1391, :znumber,             3 ],
      :ending_page_number          => [ 1392, :znumber,             3 ],
      :total_page                  => [ 1393, :ebcdic,             32 ],
      :overtime_hex                => [ 1394, :short,               2 ],
      :travel_overtime_hex         => [ 1395, :short,               2 ],
      :chargeable_time_hex         => [ 1396, :short,               2 ],
      :after_hours_time_hex        => [ 1397, :short,               2 ],
      :local_stop_time_hex         => [ 1398, :short,               2 ],
      :stop_time_moc               => [ 1399, :int,                 4 ],
      :apar_ptf_bpid_1             => [ 1440, :ebcdic,              8 ],
      :apar_ptf_bpid_2             => [ 1441, :ebcdic,              8 ],
      :apar_ptf_bpid_3             => [ 1442, :ebcdic,              8 ],
      :apar_ptf_team_date_1        => [ 1443, :ebcdic,              8 ],
      :apar_ptf_team_date_2        => [ 1444, :ebcdic,              8 ],
      :apar_ptf_team_date_3        => [ 1445, :ebcdic,              8 ],
      :apar_fix_required_date      => [ 1446, :ebcdic,              8 ],
      :apar_solution_type          => [ 1447, :ebcdic,              1 ],
      :apar_ptf_test_date          => [ 1448, :ebcdic,              1 ],
      :problem_error_description   => [ 1449, :ebcdic,             64 ],
      :local_fix_description       => [ 1450, :ebcdic,             64 ],
      :aqs_record_code_            => [ 1451, :ebcdic,              1 ],
      :aqs_routing_id_description  => [ 1452, :ebcdic,             52 ],
      :aqs_support_level_entry_    => [ 1453, :ebcdic,             67 ],
      :aqs_parent_id               => [ 1454, :ebcdic,             12 ],
      :apar_ptf_free_form_text     => [ 1455, :ebcdic,             64 ],
      :sysrouted_to_apars_counter  => [ 1456, :ebcdic,              1 ],
      :apar_sysrouted_numbers__80_ => [ 1457, :ebcdic,            720 ],
      :apar_ptf_name_of_programmer => [ 1458, :ebcdic,             30 ],
      :apar_material_submitted__16 => [ 1459, :ebcdic,            320 ],
      :apar_ptf_programmer_man_hou => [ 1460, :ebcdic,              5 ],
      :apar_ptf_system_hour        => [ 1461, :ebcdic,              5 ],
      :apar_integration_entry_poin => [ 1462, :ebcdic,              4 ],
      :apar_requested_publication_ => [ 1463, :ebcdic,             10 ],
      :apar_type_of_relief         => [ 1464, :ebcdic,              1 ],
      :apar_reason_code            => [ 1465, :ebcdic,              1 ],
      :apar_support_code           => [ 1466, :ebcdic,              8 ],
      :apar_ast_tracking_count     => [ 1467, :ebcdic,              4 ],
      :apar_interested_parties_cou => [ 1468, :ebcdic,              1 ],
      :problem_summary_in_apar_re  => [ 1469, :ebcdic,             64 ],
      :problem_conclusion_in_apar_ => [ 1470, :ebcdic,             64 ],
      :temporary_fix_in_apar_respo => [ 1471, :ebcdic,             64 ],
      :modules_macros_in_apar_resp => [ 1472, :ebcdic,             64 ],
      :slrs_in_apar_responder_page => [ 1473, :ebcdic,             64 ],
      :return_codes_in_apar_respon => [ 1474, :ebcdic,             64 ],
      :applicable_lvl_su_in_apar_r => [ 1475, :ebcdic,             64 ],
      :circumvention_in_apar_respo => [ 1476, :ebcdic,             64 ],
      :message_to_submittor_in_apa => [ 1477, :ebcdic,             64 ],
      :error_description_in_apar_r => [ 1478, :ebcdic,             64 ],
      :applicable_release_in_ptf_c => [ 1479, :ebcdic,             64 ],
      :environment_in_ptf_coverlet => [ 1480, :ebcdic,             64 ],
      :apars_fixed_from_ptf_coverl => [ 1481, :ebcdic,             64 ],
      :supersedes_from_ptf_coverle => [ 1482, :ebcdic,             64 ],
      :prerequisite_corequisite_fr => [ 1483, :ebcdic,             64 ],
      :applicable_level_from_ptf_c => [ 1484, :ebcdic,             64 ],
      :change_team_entry_count     => [ 1500, :ebcdic,              2 ],
      :fe_support_grp_entry_count  => [ 1501, :ebcdic,              2 ],
      :release_entry_count         => [ 1502, :ebcdic,              2 ],
      :backward_page_pointer       => [ 1503, :ebcdic,              1 ],
      :forward_page_pointer        => [ 1504, :ebcdic,              1 ],
      :coer_support_flag           => [ 1505, :ebcdic,              1 ],
      :short_component_id          => [ 1506, :ebcdic_zero,        11 ],
      :library                     => [ 1507, :ebcdic,              4 ],
      :component_name              => [ 1508, :ebcdic,             19 ],
      :search_library              => [ 1509, :ebcdic,              2 ],
      :apar_prefix                 => [ 1510, :ebcdic,              3 ],
      :entitlement_flag_one        => [ 1511, :ebcdic,              1 ],
      :ptf_prefix                  => [ 1512, :ebcdic,              3 ],
      :entitlement_flag_two        => [ 1513, :ebcdic,              1 ],
      :ptm_prefix                  => [ 1514, :ebcdic,              1 ],
      :fe_service_number           => [ 1515, :ebcdic,             10 ],
      :call_management_q           => [ 1516, :ebcdic,              6 ],
      :bonding_request_flag        => [ 1520, :ebcdic,              1 ],
      :required_scp_number         => [ 1521, :ebcdic,              6 ],
      :multiple_change_team_id     => [ 1522, :ebcdic,              6 ],
      :multiple_fe_support_grp_id  => [ 1523, :ebcdic,              6 ],
      :multiple_rls_table_entry    => [ 1524, :ebcdic,             28 ],
      :last_pin_key_assigned       => [ 1525, :ebcdic,              3 ],
      :search_component_id         => [ 1530, :ebcdic,             12 ],
      :external_problem_w_country  => [ 1550, :ebcdic,             10 ],
      :tdr_abstract                => [ 1608, :ebcdic,             60 ],
      :symptom_text__line          => [ 1613, :ebcdic,             64 ],
      :cstatus                     => [ 1633, :upper_ebcdic,        7 ],
      :apar_fix_component          => [ 1713, :upper_ebcdic,       12 ],
      :apar_fix_component_name     => [ 1714, :upper_ebcdic,       15 ],
      :system_flag                 => [ 1999, :ebcdic,              1 ],
      :formatted_panel_line        => [ 2133, :ebcdic,            251 ],
      :ursf_cad_text               => [ 2137, :ebcdic,            450 ],
      :problem_flag_bit            => [ 2150, :ebcdic,              1 ],
      :invalid_reason_code         => [ 2151, :ebcdic,              8 ],
      :component_id_or_device      => [ 2152, :ebcdic,             12 ],
      :onsite_prob_det_required    => [ 2153, :ebcdic,              1 ],
      :expected_duration           => [ 2154, :ebcdic,              4 ],
      :target_arrival_time         => [ 2155, :ebcdic,             12 ],
      :m_s_branch_office           => [ 2156, :ebcdic,              3 ],
      :part_number                 => [ 2157, :ebcdic,              8 ],
      :ecco_problem                => [ 2158, :ebcdic,              7 ],
      :special_message             => [ 2159, :ebcdic,             70 ],
      :contract                    => [ 2160, :ebcdic,             11 ],
      :bid_number                  => [ 2161, :ebcdic,              8 ],
      :service_contract            => [ 2162, :ebcdic,              7 ],
      :customer_claimed_contract   => [ 2163, :ebcdic,              7 ],
      :contract_type               => [ 2164, :ebcdic,              3 ],
      :origin_id                   => [ 2165, :ebcdic,              1 ],
      :customer_problem_number     => [ 2166, :ebcdic,             10 ],
      :contract_hour               => [ 2167, :ebcdic,             24 ],
      :service_hour                => [ 2168, :ebcdic,             24 ],
      :authorized_name             => [ 2169, :ebcdic,             25 ],
      :authorized_phone_number     => [ 2170, :ebcdic,             19 ],
      :cmr_customer_number         => [ 2171, :ebcdic,              7 ],
      :server_name                 => [ 2181, :ebcdic,              6 ],
      :iso_country_number          => [ 2208, :ebcdic,              2 ],
      :vantive_customer_id         => [ 2209, :ebcdic,              4 ],
      :vantive_email_selector      => [ 2210, :ebcdic,              4 ],
      :order_reference_number      => [ 2211, :ebcdic,             13 ],
      :part_number_entitled        => [ 2212, :ebcdic,              4 ],
      :remote_server_name          => [ 2213, :ebcdic,              6 ],
      :cpu_prefix                  => [ 2214, :ebcdic,              4 ],
      :customer_country            => [ 2216, :ebcdic,              3 ],
      :customer_number_x           => [ 2217, :ebcdic,              7 ],
      :cpu_type_x                  => [ 2218, :ebcdic,              4 ],
      :cpu_serial                  => [ 2219, :ebcdic,              7 ],
      :service_request             => [ 2221, :ebcdic,             11 ],
      :request_type                => [ 2417, :ebcdic,              3 ],
      :request_type_description    => [ 2418, :ebcdic,              8 ],
      :sub_request_type            => [ 2419, :ebcdic,              3 ],
      :sub_request_description     => [ 2420, :ebcdic,             30 ],
      :entitlement_code            => [ 2421, :ebcdic,              4 ],
      :contract_number             => [ 2422, :ebcdic,             20 ],
      :pid_number                  => [ 2423, :ebcdic,              7 ],
      :keyword_three               => [ 2424, :ebcdic,             15 ],
      :vrm                         => [ 2425, :ebcdic,              3 ],
      :pmr_resolver_name           => [ 2496, :ebcdic,             22 ],
      :problem_e_mail              => [ 2497, :ebcdic,             64 ],
      :pmr_resolver_id             => [ 2509, :ebcdic,              6 ],
      :monday_end_1                => [ 2672, :ebcdic,              5 ],
      :monday_end_2                => [ 2673, :ebcdic,              5 ],
      :monday_start_1              => [ 2678, :ebcdic,              5 ],
      :monday_start_2              => [ 2679, :ebcdic,              5 ]
    }
    
    def self.field_width(sym)
      FIELD_DEFINITIONS[sym][2]
    end

    attr_reader :fields, :raw_values

    def initialize(fetch_fields = nil)
      super()
      @fetch_fields = fetch_fields
      @fields = Hash.new
      @raw_values = Array.new
    end
    
    # Create @@field_num_to_name.  This is not exact -- more than one
    # symbol maps to the same index.  But this is only used for debug
    # output.
    @@field_num_to_name = Array.new
  
    FIELD_DEFINITIONS.each_pair do |k, v|
      index, convert, width = v
      @@field_num_to_name[index] = k
    end

    def self.index_to_sym(index)
      # logger.debug("RNT: index_to_sym for #{index} is #{@@field_num_to_name[index]}")
      @@field_num_to_name[index]
    end

    def self.sym_to_index(sym)
      raise "#{sym} not known as a field to retain" if (a = FIELD_DEFINITIONS[sym]).nil?
      a[0]
    end
    
    #
    # Create field getters and setters
    #
    FIELD_DEFINITIONS.dup.each_pair do |k, v|
      index, convert, width = v
      ks = k.pluralize

      # Check everything is o.k.
      raise "#{k} (singular) does not return self when singularized" if k != k.singularize
      raise "#{k} (singular) already defined" if self.method_defined?(k)
      raise "#{ks} (plural) already defined" if self.method_defined?(ks)
      raise "#{k} (singular) and #{ks} (plural) the same" if ks === k

      # Add in the plural version
      FIELD_DEFINITIONS[ks] = v

      # Create singular versions
      eval "def #{k}; reader(:#{k}, :#{convert}, #{width}); end", nil, __FILE__, __LINE__
      eval "def #{k}?; has_key?(:#{k}); end", nil, __FILE__, __LINE__
      eval "def #{k}=(data); writer(:#{k}, :#{convert}, #{width}, data); end", nil, __FILE__, __LINE__

      # Create plural versions
      eval "def #{ks}; reader(:#{ks}, :#{convert}, #{width}); end", nil, __FILE__, __LINE__
      eval "def #{ks}?; has_key?(:#{ks}); end", nil, __FILE__, __LINE__
      eval "def #{ks}=(data); writer(:#{ks}, :#{convert}, #{width}, data); end", nil, __FILE__, __LINE__

      # Create constants
      const_set(k.to_s.upcase, index)
      const_set(ks.to_s.upcase, index)
    end

    def dump_fields
      @fields.each_pair do |k, v|
        rv = v.raw_value
        if v.raw_value.nil?
          logger.error("RTN: field:#{k} is nil")
        elsif (value = v.value).is_a? Array
          logger.error("RTN: field:#{k} is #{value.inspect}")
        else
          logger.error("RTN: field:#{k} is #{value}")
        end
      end
    end

    def delete(sym)
      move_raw_value_to_field(sym)
      @fields.delete(sym)
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
    
    # We don't move it yet.  We could but I'm worried that it might
    # bite me if I do.
    def has_key?(orig_sym)
      # We can't use field_name_to_index because it raises an
      # exception for anything that is unexpected.  has_key? gets
      # called for all sorts of bogus stuff.  So, we have to do it all
      # by hand.
      sym = orig_sym.singularize
      if false
        field = FIELD_DEFINITIONS[sym]
        # logger.debug("RTN: has_key? for #{orig_sym} => #{sym}: field=#{field.inspect}")
        if field
          v = @raw_values[field[0]]
          # logger.debug("RTN: has_key? v.nil? is #{v.nil?}")
        end
        # logger.debug("RTN: has_key? @fields[sym].inspect is #{@fields[sym].inspect}")
      end
      ((field = FIELD_DEFINITIONS[sym]) && @raw_values[field[0]] && true) ||
        @fields.has_key?(sym)
    end
    
    def raw_field(sym)
      move_raw_value_to_field(sym)
      @fields[sym]
    end

    def [](sym)
      move_raw_value_to_field(sym)
      @fields[sym]
    end
    private :[]

    #
    # Used to set values received from retain into a field.  The new
    # code simply remembers these values without interpretation.
    # Later, when an access is requested, the value is interpreted.
    #
    def add_raw(index, value)
      # logger.debug("RTN: add_raw #{index} = '#{value.retain_to_user}'")
      (@raw_values[index] ||= Array.new) << value
    end

    def []=(sym, value)
      cvt = field_name_to_cvt(sym)
      width = field_name_to_width(sym)
      writer(sym, cvt, width, value)
    end

    # def each_pair
    #   @fields.each_pair do |k, v|
    #     logger.debug("RTN: v for #{k} is #{v.inspect}")
    #     if v.is_a? Array
    #       yield(k, v.map(&:value))
    #     else
    #       yield(k, v.value)
    #     end
    #   end
    #   @raw_values.each_with_index do |v, index|
    #     unless v.nil?
    #       if sym = Fields.index_to_sym(index)
    #         k = sym
    #       else
    #         k = index
    #       end
    #       if v.is_a? Array
    #         yield(k, v.map(&:value))
    #       else
    #         yield(k, v.value)
    #       end
    #     end
    #   end
    # end

    # def each_raw_pair
    #   @fields.each_pair do |k, v|
    #     yield(k, v)
    #   end
    #   @raw_values.each_with_index do |v, index|
    #     unless v.nil?
    #       if sym = Fields.index_to_sym(index)
    #         k = sym
    #       else
    #         k = index
    #       end
    #       yield(k, v)
    #     end
    #   end
    # end

    def to_debug
      r = ''
      @fields.each_pair do |k, v|
        r << "RTN: #{k}: '#{v.value.inspect}'\n"
      end
      @raw_values.each_with_index do |item, index|
        unless item.nil?
          if index > 32768
            istr = "err index #{"%4d" % (index - 32768)}"
          else
            istr = "    index #{"%4d" % index}"
          end
          value = item.map(&:retain_to_user).join(", ")
          r << "RTN: #{istr}: [#{value}]\n" unless item.nil?
        end
      end
      r
    end

    # Returns field for sym in format for a Retain request.
    def add_to_req(req, sym)
      v = get_raw_value(sym)
      index = Fields.sym_to_index(sym)
      if v.is_a? Array
        v.each { |value|
          req.data_element(index, value)
        }
      else
        req.data_element(index, v)
      end
    end

    private

    def field_name_to_index(sym)
      raise "#{sym} not known as a field to retain" if (a = FIELD_DEFINITIONS[sym]).nil?
      a[0]
    end

    def field_name_to_cvt(sym)
      raise "#{sym} not known as a field to retain" if (a = FIELD_DEFINITIONS[sym]).nil?
      a[1]
    end

    def field_name_to_width(sym)
      raise "#{sym} not known as a field to retain" if (a = FIELD_DEFINITIONS[sym]).nil?
      a[2]
    end

    def merge_fields!(new_fields)
      # logger.debug("RTN: merge_fields called")
      new_fields.fields.each_pair do |sym, v|
        # logger.debug("RTN: merge_fields: #{sym}")
        @fields[sym] = v
      end
      new_fields.raw_values.each_with_index do |item, index|
        # logger.debug("RTN: merge_fields: index #{index}") unless item.nil?
        @raw_values[index] = item
      end
    end
    
    def merge_hash!(new_fields)
      # logger.debug("RTN: merge_hash called")
      new_fields.each_pair do |sym, v|
        # if v.is_a? Array
        #   logger.debug("RTN: merge_hash: #{sym} = #{v.inspect}")
        # else
        #   logger.debug("RTN: merge_hash: #{sym} = #{v}")
        # end
        cvt = field_name_to_cvt(sym)
        width = field_name_to_width(sym)
        writer(sym, cvt, width, v)
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
    def reader(sym, cvt, width)
      # If we need to go talk to retain, figure it out here...
      flag = @fetch_fields.nil?
      # logger.debug("RTN: reader #{sym} has_key? is #{self.has_key?(sym)}, " +
      #              "@fetched=#{@fetched}, @fetch_fields.nil?=#{flag}")
      unless self.has_key?(sym) || @fetched || flag
        fetch_fields
      end

      move_raw_value_to_field(sym)
      unless (v = get_value(sym)).nil?
        return v
      end
      raise Retain::SdiDidNotReadField.new(@base_obj, sym)
    end
    
    def writer(sym, cvt, width, value)
      sym, plural = sym.to_singular_tuple
      if plural
        unless value.is_a? Array
          value = [ value ]
        end
      else
        if value.is_a? Array
          value = value[0]
        end
      end
      begin
        @fields[sym] = Field.new(cvt, width, value)
      rescue Exception => e
        raise ArgumentError, e.message + " for #{sym}", e.backtrace
      end
    end

    def move_raw_value_to_field(sym)
      # logger.debug("RTN: move_raw_value_to_field: sym=#{sym}")
      sym = sym.singularize
      # logger.debug("RTN: move_raw_value_to_field: after singularize sym=#{sym}")
      index = field_name_to_index(sym)
      # logger.debug("RTN: move_raw_value_to_field: index is #{index}")
      unless (raw_values = @raw_values[index]).nil?
        # logger.debug("RTN: raw values length = #{raw_values.length} raw_values class #{raw_values.class}")
        # logger.debug("RTN: moving raw value at index #{index} to #{sym}")
        @raw_values[index] = nil
        @fields[sym] = Field.new(field_name_to_cvt(sym),
                                 field_name_to_width(sym),
                                 raw_values,
                                 true)
      end
    end

    def get_raw_value(sym)
      xxx(sym, Field.instance_method(:raw_value))
    end

    def get_value(sym)
      xxx(sym, Field.instance_method(:value))
    end

    def xxx(osym, unbound_method)
      sym, plural = osym.to_singular_tuple
      return nil if (f = @fields[sym]).nil?
      value = unbound_method.bind(f).call
      if plural
        if value.is_a? Array
          # logger.debug("RTN: xxx: #{osym} plural array[#{value.length}]")
          value
        else
          # logger.debug("RTN: xxx: #{osym} plural value")
          [ value ]
        end
      else
        if value.is_a? Array
          # logger.debug("RTN: xxx: #{osym} singular array[#{value.length}]")
          value[0]
        else
          # logger.debug("RTN: xxx: #{osym} singular value")
          value
        end
      end
    end

    def fetch_fields
      # At the time of this call, self is the @fields in the base
      # object.  @fetch_fields.call calls the `fetch_fields' method
      # in the base object which might be, for example, a Call or
      # Pmr.  This causes us to call sendit in the base object's
      # `fetch_sdi' object which might be, for example, a Pmcb or
      # Pmpb .  The fields returned are merged back into the base
      # object's field.  The base object also has @rc.
      @base_obj = @fetch_fields.call
      @fetched = true
      unless base_obj.rc == 0
        raise Retain::SdiReaderError.new(@base_obj)
      end
    end

  end
end
