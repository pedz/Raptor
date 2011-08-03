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
  end
end
