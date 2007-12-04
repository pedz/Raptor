#
# Valid types for list request
#  '02C8'x '02C9'x, '02D6'x.
# 1:      Area (region) number CHAR(2) (2)
# 2:      Total number of lines of text for this document. This is a SEE
# 3:      Closing date - YY/MM/DD format in EBCDIC (8)
# 54:     Queue level - '1' through '6' CHAR(1) (1)
# 565:    Support center number in binary HEX(2) (2)
# 712:    RETAIN Signon. CHAR(6) (6)
# 713:    Name CHAR(22) (22)
# 714:    LCB number of user display HEX(2) (2)
# 715:    Registered RETAIN location HEX(2) (2)
# 717:    Number of secondary users HEX(2) (2)
# 718:    Corporation CHAR(3) (3)
# 719:    User's territory number CHAR(3) (3)
# 720:    Telephone number CHAR(19) (19)
# 721:    PMGT user registered authority level HEX(1) (1)
# 722:    PSAR collect indicator CHAR(1) (1)
# 723:    Daylight savings time indicator CHAR(1) (1)
# 724:    Application driver signon time HEX(4) (4)
# 725:    User's time zone adjustment factor HEX(2) (2)
# 726:    User status information HEX(1)  (1)
# 727:    Queue status flag HEX(1)  (1)
# 728:    Call symbol of dispatched call CHAR(12)  (12)
# 729:    Call symbol of pre-assigned call #1 CHAR(12) (12)
# 730:    Call symbol of pre-assigned call #2 CHAR(12) (12)
# 731:    Call symbol of pre-assigned call #3 CHAR(12) (12)
# 732:    Call symbol of pre-assigned call #4 CHAR(12) (12)
# 733:    Call symbol of pre-assigned call #5 CHAR(12) (12)
# 734:    Call symbol of pre-assigned call #6 CHAR(12) (12)
# 735:    Identification of application driver CHAR(1) (1)
# 736:    Hardware center mnemonic CHAR(3) (3)
# 737:    Hardware center number in binary HEX(2) (2)
# 738:    User's PSAR/IPAR number. CHAR(6) (6)
# 739:    User's other office worked CHAR(3) (3)
# 740:    Number of calls dispatched and pre-assigned in decimal CHAR(1) (1)
# 748:    Secondary users' employee numbers CHAR(54)  (54)
# 749:    Last shared user employee number CHAR(6) (6)
# 750:    Current secondary user on terminal CHAR(6) (6)
# 881:    Center mnemonic CHAR(3) (3)
#
# Valid types for group request
#
# 3:      Country number CHAR(3) (3)
# 27:     Problem Management queue name CHAR(6). For PMDR, queue of
# 41:     Support center number CHAR(3). For PMDR, this is the center of the
# 54:     Queue level - '1' through '6' CHAR(1) (1)
# 565:    Support center number in binary HEX(2) (2)
# 566:    Site HEX(1) (1)
# 880:    Support center name CHAR(32) (32)
# 881:    Center mnemonic CHAR(3) (3)
# 882:    Control desk employee number CHAR(6) (6)
# 883:    Control desk employee name CHAR(22) (22)
# 884:    PSAR/CESAR data collect indicator - 'Y' or 'N'. Center Control
# 885:    Center supported indicator - 'Y' or 'N' CHAR(1) (1)
# 886:    Statistics printing allowed indicator - 'Y' or 'N' CHAR(1) (1)
# 887:    Backup printing done indicator - 'Y' or 'N' CHAR(1) (1)
# 888:    Auto alarm supported indicator - 'Y' or 'N' CHAR(1) (1)
# 889:    Auto dispatch indicator - 'Y' or 'N' CHAR(1) (1)
# 890:    Queues treated equally by auto dispatch indicator - 'Y' or 'N'
# 891:    indicator - 'Y' or 'N' CHAR(1) (1)
# 892:    Center goes on daylight savings time indicator - 'Y' or 'N' CHAR(1) (1)
# 894:    Security queue CHAR(6) (6)
# 895:    PSR dispatch queue CHAR(6) (6)
# 896:    Reinsert branch office administrative queue CHAR(6) (6)
# 897:    DAF trace flag CHAR(1) (1)
# 900:    Print CR priority 1 CHAR(1) (1)
# 901:    Default priority for all queues CHAR(1) (1)
# 902:    Default category CHAR(3) (3)
# 903:    First entry in category table CHAR(5)  (5)
# 904:    Second entry in category table CHAR(5)  (5)
# 905:    Third entry in category table CHAR(5)  (5)
# 906:    Fourth entry in category table CHAR(5)  (5)
# 907:    Fifth entry in category table CHAR(5)  (5)
# 908:    Sixth entry in category table CHAR(5)  (5)
# 909:    Seventh entry in category table CHAR(5)  (5)
# 910:    Eighth entry in category table CHAR(5)  (5)
# 911:    Ninth entry in category table CHAR(5)  (5)
# 912:    Tenth entry in category table CHAR(5)  (5)
# 913:    Eleventh entry in category table CHAR(5)  (5)
# 914:    Twelfth entry in category table CHAR(5)  (5)
# 915:    LCB address for control desk HEX(4) (4)
# 916:    Printer 1 RETAIN location number HEX(2) (2)
# 917:    Printer 2 RETAIN location number HEX(2) (2)
# 918:    Call sequence number HEX(2) (2)
# 919:    Delay to time HEX(2) (2)
# 920:    Minutes from GMT HEX(2) (2)
# 921:    External system interface flag CHAR(1) (1)
# 922:    Driver ID of center controller HEX(1) (1)
# 923:    Point of control for this record HEX(1) (1)
# 924:    Absorbed queue list CHAR(160)  (160)
# 925:    Central center telephone number CHAR(19) (19)
# 926:    Lost call flag CHAR(1) (1)
# 1130:   Record identification CHAR(4)  (4)
# 1132:   Queue being monitored - 'Y' or 'N' CHAR(1) (1)
# 1133:   Queue open and activated for calls - 'Y' or 'N' CHAR(1) (1)
# 1134:   Special conditions apply - 'Y' or 'N' CHAR(1) (1)
# 1135:   Queue type is software or hardware CHAR(1). For PMDR, this is the
# 1136:   Administrative queue - 'Y' or 'N' CHAR(1) (1)
# 1137:   Description of special conditions CHAR(128) (128)
# 1138:   Queue support time, line 1. CHAR(6) (6)
# 1139:   Queue support time, line 2. CHAR(6) (6)
# 1140:   Queue support time, line 3. CHAR(6) (6)
# 1141:   Service organization CHAR(8) (8)
# 1142:   Category flag CHAR(1)  (1)
# 1143:   
# 1144:   Territory flag CHAR(1) (1)
# 1145:   Queue usage flag CHAR(1)  (1)
# 1146:   Normal response time for queue - all priorities CHAR(2) (2)
# 1147:   Normal response time flag - all priorities BIT(8)  (1)
# 1148:   Reserved for priority 2 normal response time CHAR(2) (2)
# 1149:   Reserved for priority 2 normal response time flag BIT(8) (1)
# 1150:   Reserved for priority 3 normal response time CHAR(2) (2)
# 1151:   Reserved for priority 3 normal response time flag BIT(8) (1)
# 1152:   Reserved for priority 4 normal response time CHAR(2) (2)
# 1153:   Reserved for priority 4 normal response time flag BIT(8) (1)
# 1154:   DAF control flag CHAR(1)  (1)
# 1155:   Level 1 dispatch center CHAR(3) (3)
# 1156:   Site for record being displayed HEX(1) (1)
# 1157:   Suppress problem create - 'Y' or 'N' CHAR(1) (1)
# 1158:   Alarm time interval - priority 1 HEX(2) (2)
# 1159:   DOC of last statistics update HEX(4) (4)
# 1160:   Call class 1 total length - START OF CURRENT DAY STATISTICS HEX(4) (4)
# 1161:   Call class 2 total length HEX(4) (4)
# 1162:   Call class 3 total length HEX(4) (4)
# 1163:   Call class 4 total length HEX(4) (4)
# 1164:   Call class 5 total length HEX(4) (4)
# 1165:   Call class 6 total length HEX(4) (4)
# 1166:   Call class 7 total length HEX(4) (4)
# 1167:   Call class 1 total number of calls completed HEX(2) (2)
# 1168:   Call class 2 total number of calls completed HEX(2) (2)
# 1169:   Call class 3 total number of calls completed HEX(2) (2)
# 1170:   Call class 4 total number of calls completed HEX(2) (2)
# 1171:   Call class 5 total number of calls completed HEX(2) (2)
# 1172:   Call class 6 total number of calls completed HEX(2) (2)
# 1173:   Call class 7 total number of calls completed HEX(2) (2)
# 1174:   Total number of calls completed with disposition 1 HEX(2) (2)
# 1175:   Total number of calls completed with disposition 2 HEX(2) (2)
# 1176:   Total number of calls completed with disposition 3 HEX(2) (2)
# 1177:   Total number of calls completed with disposition 4 HEX(2) (2)
# 1178:   Total number of calls completed with disposition 5 HEX(2) (2)
# 1179:   Total number of calls completed with disposition 6 HEX(2) (2)
# 1180:   Total calls deleted today HEX(2) (2)
# 1181:   Total calls dropped today HEX(2) (2)
# 1182:   Total calls handled today HEX(2) (2)
# 1183:   Total length priority 1 calls today HEX(4) (4)
# 1184:   Total response priority 1 calls today HEX(4) (4)
# 1185:   Number of priority 1 calls queued today HEX(2) (2)
# 1186:   Number of priority 1 calls dispatched today HEX(2) (2)
# 1187:   Number of priority 1 calls handled in less than an hour HEX(2) (2)
# 1188:   Total number of priority 1 calls today HEX(2) (2)
# 1189:   Max number priority 1 calls allowed on queue HEX(2) (2)
# 1190:   Number priority 1 calls queued at this time HEX(2) (2)
# 1191:   Number priority 1 calls dispatched at this time HEX(2) (2)
# 1192:   Number priority 1 calls alarmed at this time HEX(2) (2)
# 1193:   Total length priority 2 calls today HEX(4) (4)
# 1194:   Total response priority 2 calls today HEX(4) (4)
# 1195:   Number of priority 2 calls queued today HEX(2) (2)
# 1196:   Number of priority 2 calls dispatched today HEX(2) (2)
# 1197:   Number of priority 2 calls handled in less than two hours HEX(2) (2)
# 1198:   Total number of priority 2 calls today HEX(2) (2)
# 1199:   Max number priority 2 calls allowed on queue HEX(2) (2)
# 1200:   Number priority 2 calls queued at this time HEX(2) (2)
# 1201:   Number priority 2 calls dispatched at this time HEX(2) (2)
# 1202:   Number priority 2 calls alarmed at this time HEX(2) (2)
# 1203:   Total length priority 3 calls today HEX(4) (4)
# 1204:   Total response priority 3 calls today HEX(4) (4)
# 1205:   Number of priority 3 calls queued today HEX(2) (2)
# 1206:   Number of priority 3 calls dispatched today HEX(2) (2)
# 1207:   Number of priority 3 calls handled HEX(2) (2)
# 1208:   Total number of priority 3 calls today HEX(2) (2)
# 1209:   Max number priority 3 calls allowed on queue HEX(2) (2)
# 1210:   Number priority 3 calls queued at this time HEX(2) (2)
# 1211:   Number priority 3 calls dispatched at this time HEX(2) (2)
# 1212:   Number priority 3 calls alarmed at this time HEX(2) (2)
# 1213:   Total length priority 4 calls today HEX(4) (4)
# 1214:   Total response priority 4 calls today HEX(4) (4)
# 1215:   Number of priority 4 calls queued today HEX(2) (2)
# 1216:   Number of priority 4 calls dispatched today HEX(2) (2)
# 1217:   Number of priority 4 calls handled HEX(2) (2)
# 1218:   Total number of priority 4 calls today HEX(2) (2)
# 1219:   Max number priority 4 calls allowed on queue HEX(2) (2)
# 1230:   Call record page map for priority 3 calls not assigned or dispatched
# 1231:   Call record page map for priority 4 calls not assigned or dispatched
# 1232:   Alarmed time interval - priority 2 HEX(2) (2)
# 1233:   Alarmed time interval - priority 3 HEX(2) (2)
# 1234:   Alarmed time interval - priority 4 HEX(2) (2)
# 1235:   PSAR/CESAR data collect indicator - 'Y' or 'N'. Queue Control Record.
# 1280:   Number priority 4 calls queued at this time HEX(2) (2)
# 1281:   Number priority 4 calls dispatched at this time HEX(2) (2)
# 1282:   Number priority 4 calls alarmed at this time HEX(2) (2)
# 1283:   Current week statistics area CHAR(156) (156)
# 1284:   Last week statistics area CHAR(156) (156)
# 1285:   Number alarmed calls today HEX(4) (2)
# 1286:   Number alarmed calls current week HEX(4) (2)
# 1287:   Number alarmed calls last week HEX(4) (2)
# 1288:   Call record page map for priority 1 calls not assigned or dispatched
# 1289:   Call record page map for priority 2 calls not assigned or dispatched
module Retain
  class Pmqq < Sdi
    set_fetch_request "PMQQ"
    set_required_fields(:queue_name, :center, :h_or_s, :signon,
                        :password, :group_request, :list_request)

    def initialize(options = {})
      super(options)
      unless @fields.has_key?(:group_request)
        @fields[:group_request] = [
                                   :country,
                                   :queue_name,
                                   :center,
                                   :queue_level,
                                   :support_center_binary,
                                   :site,
                                   :cd_employee_number,
                                   :cd_employee_name,
                                   :special_conditions
                                  ]
      end
      unless @fields.has_key?(:list_request)
        @fields[:list_request] = [
                                  :signon2,
                                  :name,
                                  :telephone_number,
                                  :authority_level,
                                  :psar_collector_indicator,
                                  :dyalight_savings_time,
                                  :app_driver_signon,
                                  :time_zone_adjustment,
                                  :user_status_information,
                                  :queue_status_flag
                                 ]
      end
    end
  end
end
