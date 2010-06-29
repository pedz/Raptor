# -*- coding: utf-8 -*-

module Retain

# == Data elements that can be returned
#
# 3  ::  Country number CHAR(3) (3)
# 565::  Support center number in binary HEX(2) (2)
# 566::  Site HEX(1) (1)
# 880::  Support center name CHAR(32) (32)
# 881::  Center mnemonic CHAR(3) (3)
# 882::  Control desk employee number CHAR(6) (6)
# 883::  Control desk employee name CHAR(22) (22)
# 884::  PSAR/CESAR data collect indicator - 'Y' or 'N'. Center Control
#        Record. Used by (1)
# 885::  Center supported indicator - 'Y' or 'N' CHAR(1) (1)
# 886::  Statistics printing allowed indicator - 'Y' or 'N' CHAR(1) (1)
# 887::  Backup printing done indicator - 'Y' or 'N' CHAR(1) (1)
# 888::  Auto alarm supported indicator - 'Y' or 'N' CHAR(1) (1)
# 889::  Auto dispatch indicator - 'Y' or 'N' CHAR(1) (1)
# 890::  Queues treated equally by auto dispatch indicator - 'Y' or 'N'
#        CHAR(1) (1)
# 891::  Indicator - 'Y' or 'N' CHAR(1) (1)
# 892::  Center goes on daylight savings time indicator - 'Y' or 'N' CHAR(1) (1)
# 894::  Security queue CHAR(6) (6)
# 895::  PSR dispatch queue CHAR(6) (6)
# 896::  Reinsert branch office administrative queue CHAR(6) (6)
# 897::  DAF trace flag CHAR(1) (1)
# 900::  Print CR priority 1 CHAR(1) (1)
# 901::  Default priority for all queues CHAR(1) (1)
# 902::  Default category CHAR(3) (3)
# 903::  First entry in category table CHAR(5)  (5)
# 904::  Second entry in category table CHAR(5)  (5)
# 905::  Third entry in category table CHAR(5)  (5)
# 906::  Fourth entry in category table CHAR(5)  (5)
# 907::  Fifth entry in category table CHAR(5)  (5)
# 908::  Sixth entry in category table CHAR(5)  (5)
# 909::  Seventh entry in category table CHAR(5)  (5)
# 910::  Eighth entry in category table CHAR(5)  (5)
# 911::  Ninth entry in category table CHAR(5)  (5)
# 912::  Tenth entry in category table CHAR(5)  (5)
# 913::  Eleventh entry in category table CHAR(5)  (5)
# 914::  Twelfth entry in category table CHAR(5)  (5)
# 915::  LCB address for control desk HEX(4) (4)
# 916::  Printer 1 RETAIN location number HEX(2) (2)
# 917::  Printer 2 RETAIN location number HEX(2) (2)
# 918::  Call sequence number HEX(2) (2)
# 919::  Delay to time HEX(2) (2)
# 920::  Minutes from GMT HEX(2) (2)
# 921::  External system interface flag CHAR(1) (1)
# 922::  Driver ID of center controller HEX(1) (1)
# 923::  Point of control for this record HEX(1) (1)
# 924::  Absorbed queue list CHAR(160)  (160)
# 925::  Central center telephone number CHAR(19) (19)
# 926::  Lost call flag CHAR(1) (1)
#
  class Pmbc < Sdi
    set_fetch_request "PMBC"
    set_required_fields(:signon, :password)
    set_optional_fields(:group_request, :center, :owning_retain_node)

    #
    # Required Fields: :signon, :password
    #
    # Optional Fields: :group_request, :center, :owning_retain_node
    def initialize(options = {})
      super(options)
    end
  end
end
