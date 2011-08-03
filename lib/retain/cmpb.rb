# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain

  # == Component Browse
  #
  # Valid input is a choice.  I don't have a way to represent that
  # yet.  Here are the comments from the SDI document.
  # ---
  # List the component IDs or browse a specific component ID. If a
  # portion or all of a compid and the list data type are input, CMPB
  # will return a list of compids for that customer. If a compid along
  # with the group request is input, CMPB will browse that compid
  # returning that data requested within the group type.
  # ---
  # The input can be either list_request (879) with
  # search_component_id (1530) or a short_component_id (1506) with a
  # group_request (1253).  The short component_id is only 11
  # characters while others component id fields are 12.  I don't
  # understand why.  I'm going to try the list request approach first
  # and see how that flies.  The other required fields are the usual
  # signon and password (and the error message element)
  #
  # === Data Elements
  #
  # 1500::  Change team entry count CHAR(2)
  # 1501::  FE support group entry count CHAR(2)
  # 1502::  Release entry count CHAR(2)
  # 1503::  Backward page pointer (FF=first page) CHAR(1)
  # 1504::  Forward page pointer (00=last page) CHAR(1)
  # 1505::  COER support flag CHAR(1)
  # 1506::  Component ID CHAR(11)
  # 1507::  Library CHAR(4)
  # 1508::  Component name CHAR(19)
  # 1509::  Search library CHAR(2)
  # 1510::  APAR prefix CHAR(3)
  # 1511::  Entitlement flag one CHAR(1)
  # 1512::  PTF prefix CHAR(3)
  # 1513::  Entitlement flag two CHAR(1)
  # 1514::  PTM prefix CHAR(1)
  # 1515::  FE service number CHAR(10)
  # 1516::  Call management Q CHAR(6)
  # 1520::  Bonding request flag CHAR(1)
  # 1521::  Required SCP number CHAR(6)
  # 1522::  Multiple change team IDs CHAR(6)
  # 1523::  Multiple FE support group IDs CHAR(6)
  # 1524::  Multiple release table entries CHAR(28)
  # 1525::  Last pin key assigned CHAR(3)
  #
  class Cmpb < Retain::Sdi
    set_fetch_request "CMPB"
    set_required_fields(:list_request, :search_component_id, :signon, :password)
    # set_required_fields(:group_request, :short_component_id, :signon, :password)
    # set_required_fields(:signon, :password)

    # Required Fields: :list_request, :search_component_id, :signon, :password
    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
      if false
        unless @fields.has_key?(:group_request)
          @fields[:group_request] = [[
                                      # :change_team_entry_count,
                                      # :fe_support_grp_entry_count,
                                      # :release_entry_count,
                                      # :backward_page_pointer,
                                      # :forward_page_pointer,
                                      # :coer_support_flag,
                                      # :short_component_id,
                                      # :library,
                                      :component_name,
                                      # :search_library,
                                      # :apar_prefix,
                                      # :entitlement_flag_one,
                                      # :ptf_prefix,
                                      # :entitlement_flag_two,
                                      # :ptm_prefix,
                                      # :fe_service_number,
                                      # :call_management_q,
                                      # :bonding_request_flag,
                                      # :required_scp_number,
                                      :multiple_change_team_id,
                                      :multiple_fe_support_grp_id,
                                      :multiple_rls_table_entry,
                                      # :last_pin_key_assigned
                                     ]]
        end
      else      
        unless @fields.has_key?(:list_request)
          @fields[:list_request] = [[
                                     # :change_team_entry_count,
                                     # :fe_support_grp_entry_count,
                                     # :release_entry_count,
                                     # :backward_page_pointer,
                                     # :forward_page_pointer,
                                     # :coer_support_flag,
                                     :short_component_id,
                                     # :library,
                                     # :component_name,
                                     # :search_library,
                                     # :apar_prefix,
                                     # :entitlement_flag_one,
                                     # :ptf_prefix,
                                     # :entitlement_flag_two,
                                     # :ptm_prefix,
                                     # :fe_service_number,
                                     # :call_management_q,
                                     # :bonding_request_flag,
                                     # :required_scp_number,
                                     # :multiple_change_team_id,
                                     # :multiple_fe_support_grp_id,
                                     # :multiple_rls_table_entry,
                                     # :last_pin_key_assigned
                                    ]]
        end
      end
    end
  end
end
