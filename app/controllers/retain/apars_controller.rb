# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#


module Retain
  # Controller for Retain APARs.
  class AparsController < RetainController
    # Show an APAR.  Currently pulls only from Retain.
    def show
      group_request = [
                       :apar_ptf_bpid_1,
                       :comment,
                       :nls_comment,
                       :format_title,
                       :tdr_abstract,
                       :apar_abstract,
                       :symptom_text__line,
                       :apar_ptf_bpid_2,
                       :apar_ptf_bpid_3,
                       :apar_ptf_team_date_1,
                       :apar_ptf_team_date_2,
                       :apar_ptf_team_date_3,
                       :apar_fix_required_date,
                       :apar_solution_type,
                       :apar_ptf_test_date,
                       :problem_error_description,
                       :local_fix_description,
                       :aqs_record_code_,
                       :aqs_routing_id_description,
                       :aqs_support_level_entry_,
                       :aqs_parent_id,
                       :apar_ptf_free_form_text,
                       :sysrouted_to_apars_counter,
                       :apar_sysrouted_numbers__80_,
                       :apar_ptf_name_of_programmer,
                       :apar_material_submitted__16,
                       :apar_ptf_programmer_man_hou,
                       :apar_ptf_system_hour,
                       :apar_integration_entry_poin,
                       :apar_requested_publication_,
                       :apar_type_of_relief,
                       :apar_reason_code,
                       :apar_support_code,
                       :apar_ast_tracking_count,
                       :apar_interested_parties_cou,
                       :problem_summary_in_apar_re,
                       :problem_conclusion_in_apar_,
                       :temporary_fix_in_apar_respo,
                       :modules_macros_in_apar_resp,
                       :slrs_in_apar_responder_page,
                       :return_codes_in_apar_respon,
                       :applicable_lvl_su_in_apar_r,
                       :circumvention_in_apar_respo,
                       :message_to_submittor_in_apa,
                       :error_description_in_apar_r,
                       :applicable_release_in_ptf_c,
                       :environment_in_ptf_coverlet,
                       :apars_fixed_from_ptf_coverl,
                       :supersedes_from_ptf_coverle,
                       :prerequisite_corequisite_fr,
                       :applicable_level_from_ptf_c
                      ]
      size = 5
      (0 .. 3875/size).each do |start|
        group_request = ( start * size + 1 .. start * size + size )
        options = {
          :apar_number => params[:id],
          :group_request => [ group_request ]
        }
        @apar = Retain::Apar.new(retain_user_connection_parameters, options)
        @apar.fetch_fields
        sleep 1
        if @apar.rc != 0
          group_request = ( start * size + 1 .. start * size + size )
          options = {
            :apar_number => params[:id],
            :group_request => [ group_request ]
          }
          @apar = Retain::Apar.new(retain_user_connection_parameters, options)
          @apar.fetch_fields
          sleep 1
        end
      end
    end
  end
end
