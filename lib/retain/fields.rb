
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
      :area_number                => [    1, :ebcdic,        2 ],
      :branch                     => [    2, :upper_ebcdic,  3 ],
      :country                    => [    3, :upper_ebcdic,  3 ],
      :problem                    => [    4, :upper_ebcdic,  5 ],
      :customer_number            => [   11, :upper_ebcdic,  7 ],
      :customer_name              => [   14, :ebcdic,       28 ],
      :customer_contact_name      => [   19, :ebcdic,       28 ],
      :cpu_type                   => [   22, :ebcdic,        4 ],
      :priority                   => [   23, :ebcdic,        1 ],
      :queue_name                 => [   27, :upper_ebcdic,  6 ],
      :de32                       => [   32, :binary,        0 ],
      :cpu_serial_number          => [   39, :ebcdic,        7 ],
      :component_id               => [   40, :ebcdic,       12 ],
      :center                     => [   41, :upper_ebcdic,  3 ],
      :comments                   => [   42, :ebcdic,       54 ],
      :business_unit              => [   48, :ebcdic,        3 ],
      :queue_level                => [   54, :ebcdic,        1 ],
      :creator_serial             => [   87, :ebcdic,       87 ],
      :q_or_d                     => [   89, :ebcdic,        1 ],
      :nls_resolver               => [   97, :nls,          30 ],
      :nls_customer_name          => [  101, :nls,          30 ],
      :nls_contact_name           => [  102, :nls,          30 ],
      :nls_scratch_pad_1          => [  103, :nls,          74 ],
      :nls_scratch_pad_2          => [  104, :nls,          74 ],
      :nls_scratch_pad_3          => [  105, :nls,          74 ],
      :nls_text_lines             => [  107, :nls,          74 ],
      :nls_user_keyword           => [  118, :ebcdic,       16 ],
      :nominate_flag              => [  121, :ebcdic,        1 ],
      :nls_comments               => [  128, :nls,          56 ],
      :author_type                => [  131, :ebcdic,        1 ],
      :owning_retain_node         => [  132, :ebcdic,        3 ],
      :nls_pmr_owner_name         => [  133, :ebcdic,       24 ],
      :pmr_owner_phone            => [  134, :ebcdic,       19 ],
      :pmr_owner_employee_number  => [  135, :ebcdic,        6 ],
      :pmr_owner_territory        => [  136, :ebcdic,        3 ],
      :pmr_owner_name             => [  141, :ebcdic,       22 ],
      :sec_1_queue                => [  186, :ebcdic,        6 ],
      :sec_1_center               => [  187, :ebcdic,        3 ],
      :sec_1_ppg                  => [  188, :ebcdic,        2 ],
      :sec_1_h_or_s               => [  189, :ebcdic,        1 ],
      :sec_2_queue                => [  190, :ebcdic,        6 ],
      :sec_2_center               => [  191, :ebcdic,        3 ],
      :sec_2_ppg                  => [  192, :ebcdic,        2 ],
      :sec_2_h_or_s               => [  193, :ebcdic,        1 ],
      :sec_3_queue                => [  194, :ebcdic,        6 ],
      :sec_3_center               => [  195, :ebcdic,        3 ],
      :sec_3_ppg                  => [  196, :ebcdic,        2 ],
      :sec_3_h_or_s               => [  197, :ebcdic,        1 ],
      :family_offering            => [  226, :ebcdic,       12 ],
      :ret_sys_inserted_flag      => [  232, :ebcdic,        1 ],
      :ret_sys_text_and_signature => [  233, :ebcdic,        1 ],
      :return_signature_line_tail => [  234, :ebcdic,        1 ],
      :change_sig_line_name_flag  => [  235, :ebcdic,        1 ],
      :premium_response           => [  249, :ebcdic,        1 ],
      :severity_changeable        => [  250, :ebcdic,        1 ],
      :voice_response_entitled    => [  251, :ebcdic,        1 ],
      :support_center_country     => [  256, :ebcdic,        3 ],
      :release                    => [  258, :ebcdic,        3 ],
      :category                   => [  259, :ebcdic,        3 ],
      :system_tape                => [  260, :ebcdic,        4 ],
      :component_tape             => [  261, :ebcdic,        4 ],
      :environment                => [  262, :ebcdic,       18 ],
      :branch_and_country         => [  273, :ebcdic,        6 ],
      :territory                  => [  274, :ebcdic,      274 ],
      :previous_center            => [  275, :ebcdic,        3 ],
      :previous_queue             => [  276, :ebcdic,        6 ],
      :previous_priority          => [  277, :ebcdic,        1 ],
      :previous_level             => [  278, :ebcdic,        1 ],
      :previous_category          => [  279, :ebcdic,        3 ],
      :call_complete_code         => [  280, :ebcdic,        1 ],
      :crit_sit                   => [  282, :upper_ebcdic,  1 ],
      :critical_situation         => [  284, :ebcdic,        1 ],
      :call_back_time             => [  285, :ebcdic,        1 ],
      :entered_by_employee        => [  293, :ebcdic,        6 ],
      :p_s_b                      => [  298, :upper_ebcdic,  1 ],
      :dispatched_by_center       => [  301, :ebcdic,        3 ],
      :requeue_center             => [  305, :ebcdic,        3 ],
      :requeue_employee           => [  306, :ebcdic,        6 ],
      :addtxt_line                => [  331, :ebcdic,       72 ],
      :customer_account           => [  332, :ebcdic,      332 ],
      :dcsf_user_id               => [  333, :ebcdic,      333 ],
      :dcsf_node_id               => [  334, :ebcdic,        8 ],
      :user_id                    => [  335, :ebcdic,      335 ],
      :customer_problem           => [  336, :ebcdic,       14 ],
      :alterable_format_text_line => [  340, :ebcdic,       72 ],
      :formatted_panel_area       => [  341, :ebcdic,       20 ],
      :corporate_entity           => [  510, :ebcdic,      510 ],
      :director_number            => [  524, :ebcdic,        4 ],
      :dispatched_employee        => [  525, :ebcdic,        6 ],
      :pre_assigned_employee      => [  526, :ebcdic,        6 ],
      :scs0_group_request         => [  528, :binary,        0 ],
      :queue_status_flags         => [  536, :ebcdic,        1 ],
      :contact_phone_1            => [  537, :ebcdic,       19 ],
      :contact_phone_2            => [  538, :ebcdic,       19 ],
      :fup_control_count          => [  539, :ebcdic,        1 ],
      :askq_control_flags         => [  540, :ebcdic,        1 ],
      :special_application        => [  541, :ebcdic,        1 ],
      :hardware_territory         => [  542, :ebcdic,        3 ],
      :call_control_flag_1        => [  543, :ebcdic,        1 ],
      :call_queue_status_flag     => [  544, :ebcdic,        1 ],
      :original_queue             => [  545, :ebcdic,        6 ],
      :original_level             => [  546, :ebcdic,        1 ],
      :original_center            => [  547, :ebcdic,        3 ],
      :original_category          => [  548, :ebcdic,        3 ],
      :original_priority          => [  549, :ebcdic,        1 ],
      :ppg                        => [  550, :ppg,           2 ],
      :comp_id_or_alias           => [  551, :ebcdic,       12 ],
      :pmr_status_watermark       => [  552, :ebcdic,      552 ],
      :call_entered_timestamp     => [  553, :ebcdic,        4 ],
      :call_entered_by_center     => [  554, :ebcdic,        2 ],
      :call_dispatched_by_center  => [  555, :ebcdic,        2 ],
      :next_dispatch_timestamp    => [  556, :ebcdic,        4 ],
      :last_response_time         => [  557, :ebcdic,        2 ],
      :accumulated_online_time    => [  558, :ebcdic,        2 ],
      :online_start_timestamp     => [  559, :ebcdic,        4 ],
      :two_assisting_specialists  => [  560, :ebcdic,       24 ],
      :call_control_flag_2        => [  561, :ebcdic,        1 ],
      :service_given_code         => [  562, :ebcdic,        2 ],
      :acc_time_before_contact    => [  563, :ebcdic,        2 ],
      :exception_process          => [  564, :ebcdic,        1 ],
      :support_center_binary      => [  565, :ebcdic,        2 ],
      :site                       => [  566, :ebcdic,        1 ],
      :alt_level_1_dispatch       => [  567, :ebcdic,        3 ],
      :original_time_on_queue     => [  568, :ebcdic,        4 ],
      :problem_open_date          => [  569, :ebcdic,        4 ],
      :call_requeue_timestamp     => [  570, :ebcdic,        4 ],
      :call_requeue_center        => [  571, :ebcdic,        2 ],
      :number_code_1_requeues     => [  572, :ebcdic,        1 ],
      :original_response_time     => [  573, :ebcdic,        2 ],
      :last_requeue_code          => [  574, :ebcdic,        1 ],
      :machine_type_model         => [  575, :ebcdic,       10 ],
      :call_dispatch_timestamp    => [  576, :ebcdic,        4 ],
      :log_comments               => [  577, :ebcdic,       18 ],
      :call_class                 => [  578, :ebcdic,        1 ],
      :call_disposition           => [  579, :ebcdic,        1 ],
      :data_bank_use_code         => [  580, :ebcdic,        1 ],
      :data_link_use_code         => [  581, :ebcdic,        1 ],
      :region_of_call_origin      => [  582, :ebcdic,        2 ],
      :call_survey_code           => [  583, :ebcdic,        4 ],
      :call_bypass_list           => [  584, :ebcdic,       19 ],
      :profile_exceptions_message => [  596, :ebcdic,       64 ],
      :new_excessive_calls        => [  597, :ebcdic,        1 ],
      :new_excessive_problems     => [  598, :ebcdic,        1 ],
      :profile_call_branch_office => [  599, :ebcdic,        8 ],
      :profile_customer_attr_1    => [  600, :ebcdic,        8 ],
      :profile_customer_attr_2    => [  601, :ebcdic,        8 ],
      :profile_customer_attr_3    => [  602, :ebcdic,        8 ],
      :customer_time_zone_adj     => [  603, :ebcdic,        2 ],
      :time_zone_code             => [  604, :ebcdic,        2 ],
      :caller_type                => [  605, :ebcdic,        1 ],
      :time_on_queue              => [  606, :ebcdic,        4 ],
      :call_entry_accrued_time    => [  607, :ebcdic,        1 ],
      :elapsed_time_call_worked   => [  608, :ebcdic,        4 ],
      :elapsed_assist_time        => [  609, :ebcdic,        4 ],
      :problem_status_code        => [  610, :ebcdic,        6 ],
      :support_cntr_rep_territory => [  611, :ebcdic,        3 ],
      :region_number_watermark    => [  612, :ebcdic,        2 ],
      :device_type                => [  615, :ebcdic,        4 ],
      :device_model               => [  616, :ebcdic,        3 ],
      :device_serial_field        => [  617, :ebcdic,        7 ],
      :target_date                => [  618, :ebcdic,        8 ],
      :engineering_change         => [  619, :ebcdic,        9 ],
      :network_area               => [  620, :ebcdic,        2 ],
      :world_trade_region_number  => [  621, :ebcdic,        2 ],
      :offline_hours_worked       => [  622, :ebcdic,        2 ],
      :physical_assist_time       => [  623, :ebcdic,        4 ],
      :system_problem             => [  626, :ebcdic,        2 ],
      :rams_cad_key               => [  627, :ebcdic,       22 ],
      :rams_cad_flags             => [  628, :ebcdic,        1 ],
      :number_of_private_pages    => [  633, :ebcdic,        1 ],
      :branch_watermark           => [  636, :ebcdic,        3 ],
      :area_watermark             => [  640, :ebcdic,        2 ],
      :business_unit_watermark    => [  643, :ebcdic,        3 ],
      :creation_date              => [  646, :ebcdic,        9 ],
      :creation_time              => [  647, :ebcdic,        5 ],
      :alteration_date            => [  648, :ebcdic,        9 ],
      :alteration_time            => [  649, :ebcdic,        5 ],
      :apar_number                => [  650, :ebcdic,        7 ],
      :current_text_start         => [  651, :ebcdic,        1 ],
      :follow_up_info             => [  652, :ebcdic,       12 ],
      :severity                   => [  657, :ebcdic,        1 ],
      :call_search_result         => [  658, :ebcdic,        0 ],
      :sec_call_symbol_1          => [  660, :ebcdic,       12 ],
      :sec_call_symbol_2          => [  661, :ebcdic,       12 ],
      :sec_call_symbol_3          => [  662, :ebcdic,       12 ],
      :special_option_1           => [  663, :ebcdic,        3 ],
      :special_option_2           => [  664, :ebcdic,        3 ],
      :special_option_3           => [  665, :ebcdic,        3 ],
      :special_option_4           => [  666, :ebcdic,        3 ],
      :special_option_5           => [  667, :ebcdic,        3 ],
      :network_number             => [  668, :ebcdic,        9 ],
      :special_option_6           => [  669, :ebcdic,        3 ],
      :special_option_7           => [  670, :ebcdic,        3 ],
      :genesis_id                 => [  671, :ebcdic,        3 ],
      :controlled_flag            => [  672, :ebcdic,        1 ],
      :traced_product             => [  674, :ebcdic,        1 ],
      :hardware_severity          => [  677, :ebcdic,        1 ],
      :dl_log                     => [  678, :ebcdic,        5 ],
      :dl_log_2                   => [  679, :ebcdic,        5 ],
      :problem_record_flags       => [  680, :ebcdic,        1 ],
      :special_offering_flags     => [  681, :ebcdic,        1 ],
      :problem_record_flags_2     => [  682, :ebcdic,        1 ],
      :previous_severity          => [  683, :ebcdic,        1 ],
      :original_severity          => [  684, :ebcdic,        1 ],
      :country_number             => [  685, :ebcdic,      685 ],
      :branch_office              => [  686, :ebcdic,      686 ],
      :country_watermark          => [  687, :ebcdic,        3 ],
      :next_queue                 => [  692, :ebcdic,        6 ],
      :next_center                => [  693, :ebcdic,        3 ],
      :extra_flag                 => [  694, :ebcdic,        1 ],
      :serial_number_watermark    => [  696, :ebcdic,        7 ],
      :rsf_flag                   => [  698, :ebcdic,        1 ],
      :model_308x_save_area       => [  699, :ebcdic,        1 ],
      :poc_control_node           => [  701, :ebcdic,        1 ],
      :associated_data_key        => [  702, :ebcdic,        2 ],
      :associated_data_copy_list  => [  703, :ebcdic,        2 ],
      :bitstring                  => [  704, :ebcdic,        1 ],
      :problem_create_poc         => [  705, :ebcdic,        1 ],
      :call_count                 => [  706, :ebcdic,        2 ],
      :symbol_of_call_record      => [  707, :binary,       86 ],
      :purge_control_flags        => [  708, :ebcdic,        1 ],
      :last_service_code          => [  709, :ebcdic,        2 ],
      :call_problem_threshold     => [  710, :ebcdic,        2 ],
      :author_id                  => [  711, :ebcdic,        4 ],
      :embargoed_countries        => [  878, :ebcdic,        3 ],
      :iris                       => [  930, :binary,       12 ],
      :h_or_s                     => [ 1135, :upper_ebcdic,  1 ],
      :signon                     => [ 1236, :upper_ebcdic,  6 ],
      :password                   => [ 1237, :upper_ebcdic,  8 ],
      :scratch_pad_signature      => [ 1238, :ebcdic,       72 ],
      :scratch_pad_line_1         => [ 1239, :ebcdic,       72 ],
      :scratch_pad_line_2         => [ 1240, :ebcdic,       72 ],
      :scratch_pad_line_3         => [ 1241, :ebcdic,       72 ],
      :problem_type_code          => [ 1242, :ebcdic,        1 ],
      :alternate_location         => [ 1243, :ebcdic,        3 ],
      :action_code                => [ 1244, :ebcdic,        1 ],
      :action_code_2              => [ 1245, :ebcdic,        1 ],
      :askq_item_number           => [ 1246, :ebcdic,        5 ],
      :action_code_entered        => [ 1247, :ebcdic,        2 ],
      :survey_code                => [ 1248, :ebcdic,        2 ],
      :askq_status_flag           => [ 1249, :ebcdic,        1 ],
      :division                   => [ 1250, :ebcdic,        2 ],
      :askq_country_watermark     => [ 1251, :ebcdic,        9 ],
      :user_binary_id             => [ 1252, :ebcdic,        4 ],
      :pmpb_group_request         => [ 1253, :binary,        0 ],
      :sub_function_control       => [ 1254, :ebcdic,        1 ],
      :xcel_contract_number       => [ 1255, :ebcdic,        8 ],
      :flag_byte                  => [ 1256, :ebcdic,        1 ],
      :global_enterprise_number   => [ 1261, :ebcdic,       10 ],
      :seven_special_options      => [ 1262, :ebcdic,       28 ],
      :nls_street_address         => [ 1263, :nls,          19 ],
      :nls_city                   => [ 1265, :nls,          10 ],
      :city_expansion             => [ 1266, :ebcdic,       10 ],
      :nls_state                  => [ 1267, :nls,           4 ],
      :zip_code                   => [ 1268, :ebcdic,        9 ],
      :external_system_problem    => [ 1270, :ebcdic,        7 ],
      :external_system_country    => [ 1271, :ebcdic,        3 ],
      :iin_account_code           => [ 1272, :ebcdic,        8 ],
      :last_alter_timestamp       => [ 1273, :ebcdic,        6 ],
      :nls_family_abstract        => [ 1312, :nls,          53 ],
      :error_message              => [ 1384, :ebcdic,       79 ],
      :information_text_line      => [ 1390, :ebcdic,       72 ],
      :beginning_page_number      => [ 1391, :ebcdic,        3 ],
      :ending_page_number         => [ 1392, :ebcdic,        3 ],
      :total_pages                => [ 1393, :ebcdic,       32 ],
      :external_problem_w_country => [ 1550, :ebcdic,       10 ],
      :cstatus                    => [ 1633, :upper_ebcdic,  7 ],
      :problem_flag_bits          => [ 2150, :ebcdic,        1 ],
      :invalid_reason_code        => [ 2151, :ebcdic,        8 ],
      :component_id_or_device     => [ 2152, :ebcdic,       12 ],
      :onsite_prob_det_required   => [ 2153, :ebcdic,      2153 ],
      :expected_duration          => [ 2154, :ebcdic,        4 ],
      :target_arrival_time        => [ 2155, :ebcdic,       12 ],
      :m_s_branch_office          => [ 2156, :ebcdic,        3 ],
      :part_number                => [ 2157, :ebcdic,        8 ],
      :ecco_problem               => [ 2158, :ebcdic,        7 ],
      :special_message            => [ 2159, :ebcdic,       70 ],
      :contract                   => [ 2160, :ebcdic,       11 ],
      :bid_number                 => [ 2161, :ebcdic,        8 ],
      :service_contract           => [ 2162, :ebcdic,        7 ],
      :customer_claimed_contract  => [ 2163, :ebcdic,        7 ],
      :contract_type              => [ 2164, :ebcdic,        3 ],
      :origin_id                  => [ 2165, :ebcdic,        1 ],
      :customer_problem_number    => [ 2166, :ebcdic,       10 ],
      :contract_hours             => [ 2167, :ebcdic,       24 ],
      :service_hours              => [ 2168, :ebcdic,       24 ],
      :authorized_name            => [ 2169, :ebcdic,       25 ],
      :authorized_phone_number    => [ 2170, :ebcdic,       19 ],
      :cmr_customer_number        => [ 2171, :ebcdic,        7 ],
      :iso_country_number         => [ 2208, :ebcdic,        2 ],
      :vantive_customer_id        => [ 2209, :ebcdic,        4 ],
      :vantive_email_selector     => [ 2210, :ebcdic,        4 ],
      :order_reference_number     => [ 2211, :ebcdic,       13 ],
      :part_number_entitled       => [ 2212, :ebcdic,        4 ],
      :remote_server_name         => [ 2213, :ebcdic,        6 ],
      :cpu_prefix                 => [ 2214, :ebcdic,        4 ],
      :customer_country           => [ 2216, :ebcdic,        3 ],
      :customer_number_x          => [ 2217, :ebcdic,        7 ],
      :cpu_type_x                 => [ 2218, :ebcdic,        4 ],
      :cpu_serial                 => [ 2219, :ebcdic,        7 ],
      :service_request            => [ 2221, :ebcdic,       11 ],
      :request_type               => [ 2417, :ebcdic,        3 ],
      :request_type_description   => [ 2418, :ebcdic,        8 ],
      :sub_request_type           => [ 2419, :ebcdic,        3 ],
      :sub_request_description    => [ 2420, :ebcdic,       30 ],
      :entitlement_code           => [ 2421, :ebcdic,        4 ],
      :contract_number            => [ 2422, :ebcdic,       20 ],
      :pid_number                 => [ 2423, :ebcdic,        7 ],
      :keyword_three              => [ 2424, :ebcdic,       15 ]
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
      r = @fields.has_key?(index_or_sym_to_index(index))
      RAILS_DEFAULT_LOGGER.debug("DEBUG: has_key? #{index}:#{r}")
      r
    end
    
    def [](index)
      @fields[index_or_sym_to_index(index)]
    end

    #
    # Used to set values received from retain into a field
    #
    def add_raw(index, value)
      @logger.debug("DEBUG: add_raw for #{index}")
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
    
    private

    def merge_fields!(new_fields)
      new_fields.each_raw_pair do |k, v|
        index = index_or_sym_to_index(k)
        if v.is_a?(Array)
          @logger.debug("DEBUG: merge hash #{index}:Array")
        else
          @logger.debug("DEBUG: merge hash #{index}:#{v.value}")
        end
        @fields[index] = v
      end
    end
    
    def merge_hash!(new_fields)
      new_fields.each_pair do |k, v|
        index = index_or_sym_to_index(k)
        cvt = @@field_num_to_cvt[index]
        width = @@field_num_to_width[index]
        if v.is_a?(Array)
          @logger.debug("DEBUG: merge hash #{index}:Array")
        else
          @logger.debug("DEBUG: merge hash #{index}:#{v}")
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
    
    def reader(index, cvt, width)
      @logger.debug("DEBUG: reader for index #{index}")
      if f = @fields[index]
        @logger.debug("DEBUG: reading saved #{index} f.class is #{f.class}")
        return f.value
      elsif not @fetched
        @logger.debug("DEBUG: fetching fields")
        @fetch_fields.call
        if f = @fields[index]
          return f.value
        end
        @logger.debug("DEBUG: something went wrong '#{@rc}'")
      end
      super.send sym
    end
    
    def writer(index, cvt, width, value)
      @fields[index] = Field.new(cvt, width, value)
    end
  end
end

### class String
###   include Retain::FieldConverters
### end
### 
### class Array
###   def ocvt(how)
###     self
###   end
### end
