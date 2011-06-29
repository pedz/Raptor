# -*- coding: utf-8 -*-

module Retain

  #     1 -- :area_number
  #     2 -- :branch
  #     3 -- :country
  #     4 -- :problem
  #    11 -- :customer_number
  #    14 -- :customer_name
  #    19 -- :customer_contact_name
  #    22 -- :cpu_type
  #    23 -- :priority
  #    27 -- :queue_name
  #    39 -- :cpu_serial_number
  #    40 -- :component_id
  #    41 -- :center
  #    42 -- :comment
  #    48 -- :business_unit
  #    54 -- :queue_level
  #    77 -- :routing_id
  #   119 -- :assignee
  #   131 -- :author_type
  #   256 -- :support_center_country
  #   257 -- :routing_id
  #   258 -- :release
  #   259 -- :category
  #   260 -- :system_tape
  #   261 -- :component_tape
  #   262 -- :environment
  #   273 -- :branch_and_country
  #   274 -- :territory
  #   275 -- :previous_center
  #   276 -- :previous_queue
  #   277 -- :previous_priority
  #   278 -- :previous_level
  #   279 -- :previous_category
  #   280 -- :call_complete_code
  #   282 -- :open_threshold
  #   292 -- :entered_by_center
  #   293 -- :entered_by_employee
  #   301 -- :dispatched_by_center
  #   305 -- :requeue_center
  #   306 -- :requeue_employee
  #   524 -- :director_number
  #   525 -- :dispatched_employee
  #   526 -- :pre_assigned_employee
  #   536 -- :call_queue_status_flag
  #   537 -- :contact_phone_1
  #   538 -- :contact_phone_2
  #   541 -- :special_application
  #   542 -- :hardware_territory
  #   543 -- :call_control_flag_1
  #   544 -- :call_queue_status_flag
  #   545 -- :original_queue
  #   546 -- :original_level
  #   547 -- :original_center
  #   548 -- :original_category
  #   549 -- :original_priority
  #   551 -- :comp_id_or_alias
  #   553 -- :call_entered_timestamp
  #   554 -- :call_entered_by_center
  #   555 -- :call_dispatched_by_center
  #   556 -- :next_dispatch_timestamp
  #   557 -- :last_response_time
  #   558 -- :accumulated_online_time
  #   559 -- :online_start_timestamp
  #   560 -- :two_assisting_specialist
  #   561 -- :call_control_flag_2
  #   562 -- :service_given
  #   563 -- :acc_time_before_contact
  #   564 -- :exception_process
  #   565 -- :software_center
  #   566 -- :site
  #   567 -- :alt_level_1_dispatch
  #   568 -- :original_time_on_queue
  #   569 -- :problem_open_date
  #   570 -- :call_requeue_timestamp
  #   571 -- :call_requeue_center
  #   572 -- :number_code_1_requeue
  #   573 -- :original_response_time
  #   574 -- :last_requeue_code
  #   575 -- :machine_type_model
  #   576 -- :call_dispatch_timestamp
  #   577 -- :log_comment
  #   578 -- :call_class
  #   579 -- :call_disposition
  #   580 -- :data_bank_use_code
  #   581 -- :data_link_use_code
  #   582 -- :region_of_call_origin
  #   583 -- :call_survey_code
  #   584 -- :call_bypass_list
  #   596 -- :profile_exceptions_message
  #   597 -- :new_excessive_call
  #   598 -- :new_excessive_problem
  #   599 -- :profile_call_branch_office
  #   600 -- :profile_customer_attr_1
  #   601 -- :profile_customer_attr_2
  #   602 -- :profile_customer_attr_3
  #   603 -- :customer_time_zone_adj
  #   604 -- :time_zone_code
  #   605 -- :caller_type
  #   606 -- :time_on_queue
  #   607 -- :call_entry_accrued_time
  #   608 -- :elapsed_time_call_worked
  #   609 -- :elapsed_assist_time
  #   610 -- :problem_status_code
  #   611 -- :support_cntr_rep_territory
  #   615 -- :device_type
  #   616 -- :device_model
  #   617 -- :device_serial_field
  #   618 -- :target_date
  #   619 -- :engineering_change
  #   620 -- :network_area
  #   621 -- :world_trade_region_number
  #   622 -- :offline_hours_worked
  #   623 -- :physical_assist_time
  #   626 -- :system_problem
  #   627 -- :rams_cad_key
  #   628 -- :rams_cad_flag
  #   663 -- :special_option_1
  #   664 -- :special_option_2
  #   665 -- :special_option_3
  #   666 -- :special_option_4
  #   667 -- :special_option_5
  #   668 -- :network_number
  #   669 -- :special_option_6
  #   670 -- :special_option_7
  #   671 -- :genesis_id
  #  2221 -- :service_request
  #
  # Bananas are people too.
  #
  class Pmcb < Sdi
    
    set_fetch_request "PMCB"
    set_required_fields(:queue_name, :center, :ppg,
                        :h_or_s, :signon, :password,
                        :group_request)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :problem,
                                    :branch,
                                    :country,
                                    :cpu_type,
                                    :comments,
                                    :nls_customer_name,
                                    :nls_contact_name,
                                    :contact_phone_1,
                                    :contact_phone_2,
                                    :priority,
                                    :category,
                                   ]]
      end
    end
  end
end
