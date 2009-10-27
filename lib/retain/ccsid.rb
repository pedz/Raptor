# -*- coding: utf-8 -*-

module Retain
  class Ccsid
    @@ccsidtocs = Array.new
    @@ccsidtocs[   37] = "IBM-037"
    @@ccsidtocs[  256] = "IBM-256"
    @@ccsidtocs[  273] = "IBM-273"
    @@ccsidtocs[  277] = "IBM-277"
    @@ccsidtocs[  278] = "IBM-278"
    @@ccsidtocs[  280] = "IBM-280"
    @@ccsidtocs[  284] = "IBM-284"
    @@ccsidtocs[  285] = "IBM-285"
    @@ccsidtocs[  286] = "IBM-286"
    @@ccsidtocs[  290] = "IBM-290"
    @@ccsidtocs[  297] = "IBM-297"
    @@ccsidtocs[  300] = "IBM-300"
    @@ccsidtocs[  301] = "IBM-301"
    @@ccsidtocs[  367] = "IBM-367"
    @@ccsidtocs[  420] = "IBM-420"
    @@ccsidtocs[  421] = "IBM-421"
    @@ccsidtocs[  423] = "IBM-423"
    @@ccsidtocs[  424] = "IBM-424"
    @@ccsidtocs[  437] = "IBM-437"
    @@ccsidtocs[  500] = "IBM-500"
    @@ccsidtocs[  803] = "IBM-803"
    @@ccsidtocs[  813] = "IBM-813"
    @@ccsidtocs[  819] = "ISO8859-1"
    @@ccsidtocs[  833] = "IBM-833"
    @@ccsidtocs[  834] = "IBM-834"
    @@ccsidtocs[  835] = "IBM-835"
    @@ccsidtocs[  836] = "IBM-836"
    @@ccsidtocs[  837] = "IBM-837"
    @@ccsidtocs[  838] = "IBM-838"
    @@ccsidtocs[  839] = "IBM-839"
    @@ccsidtocs[  850] = "IBM-850"
    @@ccsidtocs[  851] = "IBM-851"
    @@ccsidtocs[  852] = "IBM-852"
    @@ccsidtocs[  853] = "IBM-853"
    @@ccsidtocs[  855] = "IBM-855"
    @@ccsidtocs[  856] = "IBM-856"
    @@ccsidtocs[  857] = "IBM-857"
    @@ccsidtocs[  860] = "IBM-860"
    @@ccsidtocs[  861] = "IBM-861"
    @@ccsidtocs[  862] = "IBM-862"
    @@ccsidtocs[  863] = "IBM-863"
    @@ccsidtocs[  864] = "IBM-864"
    @@ccsidtocs[  865] = "IBM-865"
    @@ccsidtocs[  868] = "IBM-868"
    @@ccsidtocs[  869] = "IBM-869"
    @@ccsidtocs[  870] = "IBM-870"
    @@ccsidtocs[  871] = "IBM-871"
    @@ccsidtocs[  874] = "TIS-620"
    @@ccsidtocs[  875] = "IBM-875"
    @@ccsidtocs[  880] = "IBM-880"
    @@ccsidtocs[  891] = "IBM-891"
    @@ccsidtocs[  897] = "IBM-897"
    @@ccsidtocs[  903] = "IBM-903"
    @@ccsidtocs[  904] = "IBM-904"
    @@ccsidtocs[  905] = "IBM-905"
    @@ccsidtocs[  912] = "IBM-912"
    @@ccsidtocs[  915] = "ISO8859-5"
    @@ccsidtocs[  916] = "IBM-916"
    @@ccsidtocs[  918] = "IBM-918"
    @@ccsidtocs[  920] = "IBM-920"
    @@ccsidtocs[  923] = "ISO8859-15"
    @@ccsidtocs[  926] = "IBM-926"
    @@ccsidtocs[  927] = "IBM-927"
    @@ccsidtocs[  928] = "IBM-928"
    @@ccsidtocs[  929] = "IBM-929"
    @@ccsidtocs[  930] = "IBM-930"
    @@ccsidtocs[  931] = "IBM-931"
    @@ccsidtocs[  932] = "IBM-932"
    @@ccsidtocs[  933] = "IBM-933"
    @@ccsidtocs[  934] = "IBM-934"
    @@ccsidtocs[  935] = "IBM-935"
    @@ccsidtocs[  936] = "IBM-936"
    @@ccsidtocs[  937] = "IBM-937"
    @@ccsidtocs[  938] = "IBM-938"
    @@ccsidtocs[  939] = "IBM-939"
    @@ccsidtocs[  942] = "IBM-942"
    @@ccsidtocs[  943] = "IBM-943"
    @@ccsidtocs[  944] = "IBM-944"
    @@ccsidtocs[  946] = "IBM-946"
    @@ccsidtocs[  948] = "IBM-948"
    @@ccsidtocs[  950] = "BIG-5"
    @@ccsidtocs[  954] = "IBM-eucJP"
    @@ccsidtocs[  964] = "IBM-eucTW"
    @@ccsidtocs[  970] = "IBM-eucKR"
    @@ccsidtocs[ 1008] = "IBM-1008"
    @@ccsidtocs[ 1010] = "IBM-1010"
    @@ccsidtocs[ 1011] = "IBM-1011"
    @@ccsidtocs[ 1012] = "IBM-1012"
    @@ccsidtocs[ 1013] = "IBM-1013"
    @@ccsidtocs[ 1014] = "IBM-1014"
    @@ccsidtocs[ 1015] = "IBM-1015"
    @@ccsidtocs[ 1016] = "IBM-1016"
    @@ccsidtocs[ 1017] = "IBM-1017"
    @@ccsidtocs[ 1018] = "IBM-1018"
    @@ccsidtocs[ 1019] = "IBM-1019"
    @@ccsidtocs[ 1025] = "IBM-1025"
    @@ccsidtocs[ 1026] = "IBM-1026"
    @@ccsidtocs[ 1027] = "IBM-1027"
    @@ccsidtocs[ 1040] = "IBM-1040"
    @@ccsidtocs[ 1041] = "IBM-1041"
    @@ccsidtocs[ 1042] = "IBM-1042"
    @@ccsidtocs[ 1043] = "IBM-1043"
    @@ccsidtocs[ 1046] = "IBM-1046"
    @@ccsidtocs[ 1089] = "ISO8859-6"
    @@ccsidtocs[ 1208] = "UTF-8"
    @@ccsidtocs[ 1252] = "IBM-1252"
    @@ccsidtocs[ 1381] = "IBM-1381"
    @@ccsidtocs[ 1383] = "IBM-eucCN"
    @@ccsidtocs[ 1386] = "GBK"
    @@ccsidtocs[ 4133] = "IBM-037"
    @@ccsidtocs[ 4352] = "IBM-256"
    @@ccsidtocs[ 4369] = "IBM-273"
    @@ccsidtocs[ 4370] = "IBM-274"
    @@ccsidtocs[ 4371] = "IBM-275"
    @@ccsidtocs[ 4372] = "IBM-276"
    @@ccsidtocs[ 4373] = "IBM-277"
    @@ccsidtocs[ 4374] = "IBM-278"
    @@ccsidtocs[ 4376] = "IBM-280"
    @@ccsidtocs[ 4378] = "IBM-282"
    @@ccsidtocs[ 4380] = "IBM-284"
    @@ccsidtocs[ 4381] = "IBM-285"
    @@ccsidtocs[ 4386] = "IBM-290"
    @@ccsidtocs[ 4393] = "IBM-297"
    @@ccsidtocs[ 4396] = "IBM-300"
    @@ccsidtocs[ 4516] = "IBM-420"
    @@ccsidtocs[ 4519] = "IBM-423"
    @@ccsidtocs[ 4520] = "IBM-424"
    @@ccsidtocs[ 4533] = "IBM-437"
    @@ccsidtocs[ 4596] = "IBM-500"
    @@ccsidtocs[ 4929] = "IBM-833"
    @@ccsidtocs[ 4932] = "IBM-836"
    @@ccsidtocs[ 4934] = "IBM-838"
    @@ccsidtocs[ 4946] = "IBM-850"
    @@ccsidtocs[ 4947] = "IBM-851"
    @@ccsidtocs[ 4948] = "IBM-852"
    @@ccsidtocs[ 4949] = "IBM-853"
    @@ccsidtocs[ 4951] = "IBM-855"
    @@ccsidtocs[ 4952] = "IBM-856"
    @@ccsidtocs[ 4953] = "IBM-857"
    @@ccsidtocs[ 4960] = "IBM-864"
    @@ccsidtocs[ 4964] = "IBM-868"
    @@ccsidtocs[ 4965] = "IBM-869"
    @@ccsidtocs[ 4966] = "IBM-870"
    @@ccsidtocs[ 4967] = "IBM-871"
    @@ccsidtocs[ 4970] = "IBM-874"
    @@ccsidtocs[ 4976] = "IBM-880"
    @@ccsidtocs[ 4993] = "IBM-897"
    @@ccsidtocs[ 5014] = "IBM-918"
    @@ccsidtocs[ 5026] = "IBM-930"
    @@ccsidtocs[ 5028] = "IBM-932"
    @@ccsidtocs[ 5029] = "IBM-933"
    @@ccsidtocs[ 5031] = "IBM-935"
    @@ccsidtocs[ 5033] = "IBM-937"
    @@ccsidtocs[ 5035] = "IBM-939"
    @@ccsidtocs[ 5050] = "IBM-eucJP"
    @@ccsidtocs[ 5348] = "IBM-1252"
    @@ccsidtocs[ 8229] = "IBM-037"
    @@ccsidtocs[ 8448] = "IBM-256"
    @@ccsidtocs[ 8476] = "IBM-284"
    @@ccsidtocs[ 8489] = "IBM-297"
    @@ccsidtocs[ 8612] = "IBM-420"
    @@ccsidtocs[ 8629] = "IBM-437"
    @@ccsidtocs[ 8692] = "IBM-500"
    @@ccsidtocs[ 9047] = "IBM-855"
    @@ccsidtocs[ 9056] = "IBM-864"
    @@ccsidtocs[ 9060] = "IBM-868"
    @@ccsidtocs[ 9089] = "IBM-897"
    @@ccsidtocs[ 9122] = "IBM-930"
    @@ccsidtocs[ 9135] = "IBM-943"
    @@ccsidtocs[ 9146] = "IBM-eucJP"
    @@ccsidtocs[12325] = "IBM-037"
    @@ccsidtocs[12544] = "IBM-256"
    @@ccsidtocs[12725] = "IBM-437"
    @@ccsidtocs[12788] = "IBM-500"
    @@ccsidtocs[13152] = "IBM-864"
    @@ccsidtocs[13218] = "IBM-930"
    @@ccsidtocs[13219] = "IBM-931"
    @@ccsidtocs[13231] = "IBM-943"
    @@ccsidtocs[13242] = "IBM-eucJP"
    @@ccsidtocs[13488] = "UCS-2"
    @@ccsidtocs[16421] = "IBM-037"
    @@ccsidtocs[16821] = "IBM-437"
    @@ccsidtocs[16884] = "IBM-500"
    @@ccsidtocs[20517] = "IBM-037"
    @@ccsidtocs[20917] = "IBM-437"
    @@ccsidtocs[20980] = "IBM-500"
    @@ccsidtocs[24613] = "IBM-037"
    @@ccsidtocs[24877] = "IBM-301"
    @@ccsidtocs[25013] = "IBM-437"
    @@ccsidtocs[25076] = "IBM-500"
    @@ccsidtocs[25426] = "IBM-850"
    @@ccsidtocs[25427] = "IBM-851"
    @@ccsidtocs[25428] = "IBM-852"
    @@ccsidtocs[25429] = "IBM-853"
    @@ccsidtocs[25431] = "IBM-855"
    @@ccsidtocs[25432] = "IBM-856"
    @@ccsidtocs[25433] = "IBM-857"
    @@ccsidtocs[25436] = "IBM-860"
    @@ccsidtocs[25437] = "IBM-861"
    @@ccsidtocs[25438] = "IBM-862"
    @@ccsidtocs[25439] = "IBM-863"
    @@ccsidtocs[25440] = "IBM-864"
    @@ccsidtocs[25441] = "IBM-865"
    @@ccsidtocs[25444] = "IBM-868"
    @@ccsidtocs[25445] = "IBM-869"
    @@ccsidtocs[25450] = "IBM-874"
    @@ccsidtocs[25467] = "IBM-891"
    @@ccsidtocs[25473] = "IBM-897"
    @@ccsidtocs[25479] = "IBM-903"
    @@ccsidtocs[25480] = "IBM-904"
    @@ccsidtocs[25502] = "IBM-926"
    @@ccsidtocs[25503] = "IBM-927"
    @@ccsidtocs[25504] = "IBM-928"
    @@ccsidtocs[25505] = "IBM-929"
    @@ccsidtocs[25508] = "IBM-932"
    @@ccsidtocs[25510] = "IBM-934"
    @@ccsidtocs[25512] = "IBM-936"
    @@ccsidtocs[25514] = "IBM-938"
    @@ccsidtocs[25518] = "IBM-942"
    @@ccsidtocs[25520] = "IBM-944"
    @@ccsidtocs[25522] = "IBM-946"
    @@ccsidtocs[25524] = "IBM-948"
    @@ccsidtocs[25616] = "IBM-1040"
    @@ccsidtocs[25617] = "IBM-1041"
    @@ccsidtocs[25618] = "IBM-1042"
    @@ccsidtocs[25619] = "IBM-1043"
    @@ccsidtocs[28709] = "IBM-037"
    @@ccsidtocs[29109] = "IBM-437"
    @@ccsidtocs[29172] = "IBM-500"
    @@ccsidtocs[29522] = "IBM-850"
    @@ccsidtocs[29523] = "IBM-851"
    @@ccsidtocs[29524] = "IBM-852"
    @@ccsidtocs[29525] = "IBM-853"
    @@ccsidtocs[29527] = "IBM-855"
    @@ccsidtocs[29528] = "IBM-856"
    @@ccsidtocs[29529] = "IBM-857"
    @@ccsidtocs[29532] = "IBM-860"
    @@ccsidtocs[29533] = "IBM-861"
    @@ccsidtocs[29534] = "IBM-862"
    @@ccsidtocs[29535] = "IBM-863"
    @@ccsidtocs[29536] = "IBM-864"
    @@ccsidtocs[29537] = "IBM-865"
    @@ccsidtocs[29540] = "IBM-868"
    @@ccsidtocs[29541] = "IBM-869"
    @@ccsidtocs[29546] = "IBM-874"
    @@ccsidtocs[29614] = "IBM-942"
    @@ccsidtocs[29616] = "IBM-944"
    @@ccsidtocs[29618] = "IBM-946"
    @@ccsidtocs[29620] = "IBM-948"
    @@ccsidtocs[29712] = "IBM-1040"
    @@ccsidtocs[29713] = "IBM-1041"
    @@ccsidtocs[29714] = "IBM-1042"
    @@ccsidtocs[29715] = "IBM-1043"
    @@ccsidtocs[32805] = "IBM-037"
    @@ccsidtocs[33058] = "IBM-290"
    @@ccsidtocs[33205] = "IBM-437"
    @@ccsidtocs[33268] = "IBM-500"
    @@ccsidtocs[33618] = "IBM-850"
    @@ccsidtocs[33619] = "IBM-851"
    @@ccsidtocs[33620] = "IBM-852"
    @@ccsidtocs[33621] = "IBM-853"
    @@ccsidtocs[33623] = "IBM-855"
    @@ccsidtocs[33624] = "IBM-856"
    @@ccsidtocs[33632] = "IBM-864"
    @@ccsidtocs[33636] = "IBM-868"
    @@ccsidtocs[33637] = "IBM-869"
    @@ccsidtocs[33665] = "IBM-897"
    @@ccsidtocs[33698] = "IBM-930"
    @@ccsidtocs[33699] = "IBM-931"
    @@ccsidtocs[33700] = "IBM-932"
    @@ccsidtocs[33722] = "IBM-eucJP"
    @@ccsidtocs[37301] = "IBM-437"
    @@ccsidtocs[37364] = "IBM-500"
    @@ccsidtocs[37719] = "IBM-855"
    @@ccsidtocs[37728] = "IBM-864"
    @@ccsidtocs[37732] = "IBM-868"
    @@ccsidtocs[37761] = "IBM-897"
    @@ccsidtocs[37796] = "IBM-932"
    @@ccsidtocs[41397] = "IBM-437"
    @@ccsidtocs[41460] = "IBM-500"
    @@ccsidtocs[41824] = "IBM-864"
    @@ccsidtocs[41828] = "IBM-868"
    @@ccsidtocs[45493] = "IBM-437"
    @@ccsidtocs[45556] = "IBM-500"
    @@ccsidtocs[45920] = "IBM-864"
    @@ccsidtocs[49589] = "IBM-437"
    @@ccsidtocs[49652] = "IBM-500"
    @@ccsidtocs[53748] = "IBM-500"
    @@ccsidtocs[61696] = "IBM-500"
    @@ccsidtocs[61697] = "IBM-850"
    @@ccsidtocs[61698] = "IBM-850"
    @@ccsidtocs[61699] = "IBM-813"
    @@ccsidtocs[61700] = "IBM-367"
    @@ccsidtocs[61712] = "IBM-500"

    def self.to_cs(index)
      @@ccsidtocs[index] || "IBM-037"
    end
  end
end
