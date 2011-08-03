# -*- coding: utf-8 -*-
#
# Copyright 2007-2011 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#

module Retain
  # == Add Text
  # === Data Elements
  #
  # 2:: Branch office number CHAR(3) (3)
  # 3:: Country number CHAR(3) (3)
  # 4:: Problem record number. If user assigns a problem number in PMCE it
  #     must be numeric and data element 206 must be input and set to
  #     "Y". (5)
  # 41:: Support center number CHAR(3). For PMDR, this is the center of the
  #      call to which the user is dispatched. (3)
  # 107:: NLS text lines with CCSID Format (CCSID || Text line) (varies)
  # 331:: Problem Record Addtext Line - Varying character length up to 72.
  #       Trailing blanks are removed from the text lines. Blank lines are
  #       represented as a text line with one blank (i.e. a data element length
  #       of 5, 4 for the data element header, 1 for a blank - '40'X). The
  #       maximum number of addtext lines is 860. For PMPB, the 331 data type
  #       deals only with fixed length of 72 bytes, it is not a varying length. (72)
  # 590:: Signature line CHAR(72) (72)
  # 629:: Type of formatted panel operation CHAR(2) <o:p></o:p> (2)
  # 630:: Formatted panel number CHAR(4) (4)
  # 631:: Problem record formatted panel <o:p></o:p> (variable)
  # 632:: Panel Operand CHAR(1) (1)
  # 713:: Name CHAR(22) (22)
  # 930:: IRIS file and symbol CHAR(12) (12)
  # 1236:: Users RETAIN signon CHAR(6) (6)
  # 1237:: Users RETAIN password CHAR(8) (8)
  # 1253:: Indicates a group of data types. The 1253 GROUP data type is input
  #        followed by the data types that represent the fields the remote system
  #        would like RETAIN to return. The length depends upon the number of
  #        data types in the group. (varies)
  # 1261:: Global enterprise number CHAR(10) (10)
  # 1273:: Last alter timestamp in problem record (6)
  # 1384:: Error message to return to remote system (79)
  # 1390:: Problem Record Information Text Line - Varying character length up to 72.
  #        Trailing blanks are removed from the text lines. Blank lines are
  #        represented as a text line with one blank (i.e. a data element length
  #        of 5, 4 for the data element header, 1 for a blank - '40'X). The
  #        maximum number of information text lines is 48. For PMPB the 1390 data
  #        element deals only with fixed length of 72 bytes, it is not a varying
  #        length. (72)
  # 1820:: NSS Add Text (27)
  # 1821:: NSS Action Add Text (27)
  # 1822:: NSS Parts Add Text <o:p></o:p> (74)
  # 1827:: NSS RRMSG Text (66)
  # 1828:: (3)
  # 1829:: NSS RRMSG Destination Employee (6)
  # 1830:: NSS Status Code send - STCD xx (2)
  # 2133:: Formatted Panel Line (CHAR 251) (251)
  class Pmat < Retain::Sdi
    set_fetch_request "PMAT"
    set_required_fields(:signon, :password, :problem, :branch, :country)
    set_optional_fields(:addtxt_lines)

    def initialize(retain_user_connection_parameters, options = {})
      super(retain_user_connection_parameters, options)
    end
  end
end
