# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  class ComponentsController < RetainController
    def index
      @component = Retain::Component.new(retain_user_connection_parameters, :search_component_id => "5           ")
      @component.send(:short_component_id)
      render :text => "hi"
    end

    def show
      # @component = Retain::Component.new(:search_component_id => params[:id])
      @component = Retain::Component.new(retain_user_connection_parameters,
                                         :short_component_id => params[:id],
                                         :group_request => [[
                                                             :change_team_entry_count,
                                                             :fe_support_grp_entry_count,
                                                             :release_entry_count,
                                                             :backward_page_pointer,
                                                             :forward_page_pointer,
                                                             :coer_support_flag,
                                                             :short_component_id,
                                                             :library,
                                                             :component_name,
                                                             :search_library,
                                                             :apar_prefix,
                                                             :entitlement_flag_one,
                                                             :ptf_prefix,
                                                             :entitlement_flag_two,
                                                             :ptm_prefix,
                                                             :fe_service_number,
                                                             :call_management_q,
                                                             :bonding_request_flag,
                                                             :required_scp_number,
                                                             :multiple_change_team_id,
                                                             :multiple_fe_support_grp_id,
                                                             :multiple_rls_table_entry,
                                                             :div
                                                            ]]
                                         )
      @component.send(:component_name)
    end

    # this is not a super logical place to put this.
    # This get request returns the complicated OPC data starting at
    # the requested component and working down.
    def opc
      @component = ::Component.find_by_retain_comp_id(params[:id])
      render :json => @component.to_json(:include => {
                                           :opc_group => {},
                                           :question_set => {
                                             :include => {
                                               :question_set_versions => {
                                                 :include => {
                                                   :base_version => {
                                                     :include => {
                                                       :root_question => {
                                                         :include => {
                                                           :opc_information => {
                                                             :include => {
                                                               :children => {
                                                                 :include => {
                                                                   :question => {},
                                                                   :opc_dependency => {},
                                                                   :children => {
                                                                     :include => {
                                                                       :answer => {}
                                                                     }
                                                                   }
                                                                 }
                                                               }
                                                             }
                                                           }
                                                         }
                                                       }
                                                     }
                                                   },
                                                   :root_question => {
                                                     :include => {
                                                       :opc_information => {
                                                         :include => {
                                                           :children => {
                                                             :include => {
                                                               :question => {},
                                                               :opc_dependency => {},
                                                               :children => {
                                                                 :include => {
                                                                   :answer => {}
                                                                 }
                                                               }
                                                             }
                                                           }
                                                         }
                                                       }
                                                     }
                                                   }
                                                 }
                                               }
                                             }
                                           },
                                           :component_versions => {},
                                           :target_components => {},
                                           :overwritten_descriptions => {},
                                           :ignore_base_items => {}
                                         })
    end
  end
end
