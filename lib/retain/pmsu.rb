# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  #    9 -  Search argument. In general, search arguments can be up to 126
  #         characters, 15 words. For transactions SAP0 and SEL1: (1) it is
  #         limited to 122 characters, 14 words, and (2) if a last change date is
  #         supplied, the search argument is limited to 102 characters and 13
  #         words. For the HSSU transaction: the limit varies depending on the
  #         type of user and that user's authority. Because room is needed to
  #         append information about the user, the search argument should be less
  #         than 98 characters. (126)
  #   11 -  Binary number of search hits. This value may be different from the
  #         number of document ID's (data element 13). (4)
  #   32 -  New for R4. This data element will consist of a total data element
  #         length (fixed binary 15), followed by data element type (fixed binary
  #         15), followed by data. &quot;Super Data Element&quot; The data portion
  #         will consist of a number of structures in the format llttdata where ll
  #         is the length, tt is the type, and &quot;data&quot; is the actual
  #         data. This structure (llttdata) will be repeated for as many pieces of
  #         data as will be returned. See <a
  #         href="https://longspeak.boulder.ibm.com/RETAIN/docs/SDI.HTML#TBLETR032#TBLETR032"><span
  #         style="mso-bidi-font-size:12.0pt">Table 17</span></a> for the layout
  #         of this data type. (varies)
  #  585 -  Operand CHAR(4) (4)
  #  591 -  Number of hits to return up to 5000
  #  930 -  IRIS file and symbol CHAR(12) (12)
  # 1135 -  Queue type is software or hardware CHAR(1). For PMDR, this is the
  #         type of the call to which the user is dispatched. For PMPB transaction
  #         this data type is retrieved from the primary call symbol. (1)
  # 1236 -  Users RETAIN signon CHAR(6) (6)
  # 1237 -  Users RETAIN password CHAR(8) (8)
  # 1253 -  Indicates a group of data types. The 1253 GROUP data type is input
  #         followed by the data types that represent the fields the remote system
  #         would like RETAIN to return. The length depends upon the number of
  #         data types in the group. (varies)
  class Pmsu < Retain::Sdi
    
    set_fetch_request "PMSU"
    set_required_fields :search_argument, :signon, :password, :group_request
    set_optional_fields :operand, :h_or_s, :hit_limit
    
    def initialize(retain_user_connection_parameters, options = { })
      super(retain_user_connection_parameters, options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [[
                                    :problem,
                                    :branch,
                                    :country,
                                    :last_alter_timestamp,
                                    :alteration_date,
                                    :alteration_time
                                   ]]
      end
    end
  end
end
