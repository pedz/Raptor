# 1     Area (region) number CHAR(2) (2)
# 2     Total number of lines of text for this document. This is a SEE
# 3     Closing date - YY/MM/DD format in EBCDIC (8)
# 27    Problem Management queue name CHAR(6). For PMDR, this is the queue of
# 41    Support center number CHAR(3). For PMDR, this is the center of the
# 48    Business unit CHAR(3) (3)
# 54    Queue level - '1' through '6' CHAR(1) (1)
# 143   ESP product number (ESPnnnn) CHAR(7) (7)
# 198   Retain user has CTLAUTH authority (Y/N) (1)
# 550   Priority and page number for call record (2)
# 565   Support center number in binary HEX(2) (2)
# 712   RETAIN Signon. CHAR(6) (6)
# 713   Name CHAR(22) (22)
# 714   LCB number of user display HEX(2) (2)
# 715   Registered RETAIN location HEX(2) (2)
# 716   Absorb list entries CHAR(80)  (80)
# 717   Number of secondary users HEX(2) (2)
# 718   Corporation CHAR(3) (3)
# 719   User's territory number CHAR(3) (3)
# 720   Telephone number CHAR(19) (19)
# 721   PMGT user registered authority level HEX(1) (1)
# 722   PSAR collect indicator CHAR(1) (1)
# 723   Daylight savings time indicator CHAR(1) (1)
# 724   Application driver signon time HEX(4) (4)
# 725   User's time zone adjustment factor HEX(2) (2)
# 726   User status information HEX(1)  (1)
# 727   Queue status flag HEX(1)  (1)
# 728   Call symbol of dispatched call CHAR(12)  (12)
# 729   Call symbol of pre-assigned call #1 CHAR(12) (12)
# 730   Call symbol of pre-assigned call #2 CHAR(12) (12)
# 731   Call symbol of pre-assigned call #3 CHAR(12) (12)
# 732   Call symbol of pre-assigned call #4 CHAR(12) (12)
# 733   Call symbol of pre-assigned call #5 CHAR(12) (12)
# 734   Call symbol of pre-assigned call #6 CHAR(12) (12)
# 735   Identification of application driver CHAR(1) (1)
# 736   Hardware center mnemonic CHAR(3) (3)
# 737   Hardware center number in binary HEX(2) (2)
# 738   User's PSAR/IPAR number. CHAR(6) (6)
# 739   User's other office worked CHAR(3) (3)
# 740   Number of calls dispatched and pre-assigned in decimal CHAR(1) (1)
# 741   Number of entries on primary list HEX(1) (1)
# 742   Number of entries on secondary list HEX(1) (1)
# 743   Number of entries on absorb list HEX(1) (1)
# 744   Primary product support list CHAR(60)  (60)
# 745   Secondary product support list CHAR(120)  (120)
# 748   Secondary users' employee numbers CHAR(54)  (54)
# 749   Last shared user employee number CHAR(6) (6)
# 750   Current secondary user on terminal CHAR(6) (6)
# 753   Number of software logical library keys CHAR(1) (1)
# 754   List of software logical library keys CHAR(30) (30)
# 756   Number of hardware logical library keys CHAR(1) (1)
# 758   List of hardware logical library keys CHAR(30) (30)
# 759   System GMT in minute of century (MOC) (4)
# 881   Center mnemonic CHAR(3) (3)
# 1135  Queue type is software or hardware CHAR(1). For PMDR, this is the
# 1330  User's authority code HEX(1) (1)
# 1331  RETAIN location area number or plant number HEX(1) (1)
# 1332  Time of day user signed on in binary minutes HEX(2) (2)
# 1333  Date user last signed on CHAR(6) (6)
# 1334  Total accumulated time in binary minutes HEX(4) (4)
# 1335  Alternate registration ID CHAR(1) (1)
# 1336  Code for this user CHAR(1)  (1)
# 1337  Flag HEX(1)  (1)
# 1338  Default CCSID for user's terminal CHAR(2) (2)
# 1339  User default CCSID flag HEX(1)  (1)
# 1340  Date of user registration to RETAIN CHAR(6) (6)
# 1341  Terminal ID (LCB number) where user is signed on HEX(2) (2)
# 1342  Terminal from which last update made CHAR(8) (8)
# 1343  User profile CHAR(40) (40)
# 1345  Array of up to nine binary field IDs for the PTF summary page title
# 1346  Telephone number CHAR(20) (20)
# 1347  Security 30 day check date HEX(4) (4)
# 1348  User security key structure. CHAR(9)  (9)
# 1349  Number of binary field IDs for PTF summary page title build in binary
# 1350  Department number CHAR(22) (22)
# 1351  Building number CHAR(22) (22)
# 1352  Zip code CHAR(6) (6)
# 1353  Last registration level source CHAR(3) (3)
# 1354  Last updater ID (packed) CHAR(3) (3)
# 1355  Authority for TC visibility HEX(1)  (1)
# 1356  Last POC signed on CHAR(1) (1)
# 1357  Street address CHAR(32) (32)
# 1358  City, state and zip code CHAR(32) (32)
# 1359  RETAIN router facility function mask CHAR(32) (32)
# 1360  Attempt downward compatibility default library/file length HEX(1) (1)
# 1361  Attempt downward compatibility library/file defaults CHAR(7) (7)
# 1362  Iris default length HEX(1) (1)
# 1363  Iris default CHAR(87) (87)
# 1364  Change team entry count in binary HEX(2) (2)
# 1365  Array of up to 20 change team IDs CHAR(80)  (80)
# 1366  Number of binary field IDs for the APAR summary page title build
# 1367  Array of up to nine binary field IDs for the APAR summary page title
# 1368  Duration of the user's last RETAIN session CHAR(2) (2)
# 1369  Application driver initialization time CHAR(4) (4)
# 1370  Application driver initialization date CHAR(4) (4)
# 1371  Terminal controller symbolic ID CHAR(8) (8)
# 1372  Application mask 1 CHAR(32) (32)
# 1373  Application mask 2 CHAR(32) (32)
# 1374  Application mask 3 CHAR(32) (32)
# 1375  Application mask 4 CHAR(32) (32)
# 2100  3rd Oldest Password Length (CHAR 1) (1)
# 2101  3rd Oldest Password (CHAR 8) (8)
# 2102  2nd Oldest Password Length (CHAR 1) (1)
# 2103  2nd Oldest Password (CHAR 8) (8)
# 2104  Last Password Length (CHAR 1) (1)
# 2105  Last Password (CHAR 8) (8)
# 2107  Current Password (CHAR 8) (8)
# 2108  Password Update, Day of Century (CHAR 4) (4)
# 2109  DB Throttle Date, Julian (CHAR 2) (2)
# 2110  DB Throttle Trigger (CHAR 4) (4)
# 2111  Department Number (CHAR 8) (8)
# 2112  Contractor, Y/N (CHAR 1) (1)
# 2113  Business Number (CHAR 2) (2)
# 2114  Organization Level 1 (CHAR 1) (1)
# 2115  Organization Level 2 (CHAR 1) (1)
# 2116  VM Node to Receive Password (CHAR 8) (8)
# 2118  Current Password (CHAR 8) (8)
# 2119  Last Password (CHAR 8) <span style="mso-spacerun:yes"> </span> (8)
# 2120  PEND Access restriction (CHAR 8) (8)
# 2121  Net Name of Users System (CHAR 8) (8)
# 2122  Users Associated Printer ID (CHAR 8) (8)
# 2123  Customer Number (CHAR 7) (7)
# 2124  Users Language (CHAR 1) (1)
# 2125  Password Expired, Y/N (CHAR 1) (1)
# 2126  Password Expires, Day of Century (CHAR 4) (4)
# 2131  Problem Management Registration Data Flag (BIT 8)  (1)
# 2132  Problem Management Client Source ID (CHAR 3) (3)
# 2139  Problem Management CPU library selected. (1)
# 2220  Last signed-on time. (10)


module Retain
  class Pmdr < Sdi
    set_fetch_request "PMDR"
    set_required_fields :signon, :password, :group_request
    set_optional_fields :secondary_login

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [
                                   :name,
                                   :queue_name,
                                   :center,
                                   :h_or_s,
                                   :absorb_support_list,
                                   :num_primary_list,
                                   :num_secondary_list,
                                   :num_absorb_list,
                                   :primary_support_list,
                                   :secondary_support_list
                                  ]
      end
    end
  end
end
