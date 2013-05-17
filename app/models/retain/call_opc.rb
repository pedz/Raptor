# -*- coding: utf-8 -*-
#
# Copyright 2013 Ease Software, Inc. and Perry Smith
# All Rights Reserved
#
module Retain
  class CallOpc
    class ComponentGroup
      attr_reader :group_text
      attr_reader :children
      
      def initialize(group_text, children)
        @group_text = group_text
        @children = children.map { |h| Component.new(h) }
      end
    end

    class Component
      def initialize(hash)
        @hash = hash
      end

      def text
        @hash[:text]
      end

      def value
        "xxxxxxxxxxxxxxxxxxxxx%-4sxxxxxxxxxxxxxxxxxxxxx" % @hash[:value]
      end
    end
    
    attr_reader   :call
    attr_accessor :qset
    attr_accessor :comp
    
    def initialize(call)
      @call = call
      @qset = 'Q007'
      @comp = nil
    end

    def kv
      @kv ||=
        [
         {
           name: 'time',
           code: '@',
           restriction: '0 == 1',
           function: 'user_time',
           value: '18'
         },
         {
           name: 'user',
           code: '#',
           restriction: '0 == 1',
           function: 'user_name',
           value: '__user'
         },
         {
           name: 'date',
           code: '$',
           restriction: '0 == 1',
           function: 'get_date',
           value: Time.now.strftime('%Y-%m-%d')
         },
         {
           name: 'Q1',
           code: 'O',
           restriction: '0 == 1',
           text: 'Outage?',
           description: 'Outage: a critical system partition is down/unusable, a critical application is hung/unusable, there is no access to data, performance is impacting the ability to do business, an install/RA is exceeding the maint window or a backup system/appl is down.',
           response: [ { text: 'No',  value: 'N' },
                       { text: 'Yes', value: 'Y' } ]

         },
         {
           name: 'Q2',
           code: 'T',
           restriction: '$Q1 == N',
           text: 'Outage type?',
           description: 'Which piece/criteria of the outage definition did this PMR meet?',
           response: [ { text: 'Critical system partition down',         value: 'S' },
                       { text: 'Critical application hung',              value: 'A' },
                       { text: 'No access to data',                      value: 'D' },
                       { text: 'Performance impacted business',          value: 'P' },
                       { text: 'Install/RA exceeded maintenance window', value: 'I' },
                       { text: 'Backup system/application down',         value: 'B' } ]
         },
         {
           name: 'Q3',
           code: 'C',
           restriction: '$Q1 == N',
           text: 'Crash or hang?',
           description: 'Did this problem result in a crash or hang affecting a single or multiple partitions?',
           response: [ { text: 'No',  value: 'N' },
                       { text: 'Yes', value: 'Y' } ]
         },
         {
           name: 'Q4',
           code: 'D',
           restriction: '$Q1 == N || $Q3 == N',
           text: 'Outage duration?',
           description: 'How long was the critical system partition down/unusable, the critical application hung/unusable, the lack of access to data, the performance impact, the install/RA time or the backup system/appl down?',
           response: [ { text: '<= 30 minutes',        value: '30' },
                       { text: '<= 1 hour',            value: '1' },
                       { text: '<= 2 hours',           value: '2' },
                       { text: '<= 4 hours',           value: '4' },
                       { text: 'Greater than 4 hours', value: 'G' },
                       { text: 'Unknown',              value: 'U' } ]
         },
        ]
    end

    def to_id
      @_to_id ||= @call.to_id
    end

    def id
      @_id ||= @call.id
    end
    
    def to_param
      @_to_param ||= @call.to_param
    end

    def component_groups
      @components ||= FixedComponents.
        group_by { |h| h[:group] }.
        map { |key, value| ComponentGroup.new(key, value) }
    end
    
    FixedComponents =
      [
       { group: "Boot/Bring up",           text: "Boot/Bring up",                         value: "BOOT" },
       { group: "CMDS/LIBS/Security",      text: "CMDS/LIBS/Security",                    value: "CLS"  },
       { group: "CMDS/LIBS/Security",      text: "Accounting",                            value: "ACCT" },
       { group: "CMDS/LIBS/Security",      text: "AIX based OS commands",                 value: "ACMD" },
       { group: "CMDS/LIBS/Security",      text: "AIX malloc subsystem",                  value: "AMAL" },
       { group: "CMDS/LIBS/Security",      text: "AIX Runtime Expert",                    value: "ARUN" },
       { group: "CMDS/LIBS/Security",      text: "AIX Security Expert",                   value: "ASEC" },
       { group: "CMDS/LIBS/Security",      text: "Audit",                                 value: "AUDT" },
       { group: "CMDS/LIBS/Security",      text: "Authentication (LAM, PAM, LDAP, KRB5)", value: "AUTH" },
       { group: "CMDS/LIBS/Security",      text: "Based system libraries (libc)",         value: "SLIB" },
       { group: "CMDS/LIBS/Security",      text: "DBX",                                   value: "CDBX" },
       { group: "CMDS/LIBS/Security",      text: "Multi-level Security",                  value: "MLS"  },
       { group: "CMDS/LIBS/Security",      text: "Role Based Access Control",             value: "RBAC" },
       { group: "CMDS/LIBS/Security",      text: "Security commands",                     value: "SECC" },
       { group: "CMDS/LIBS/Security",      text: "Shells",                                value: "SHEL" },
       { group: "CMDS/LIBS/Security",      text: "Time Zone (POSIX)",                     value: "TMZN" },
       { group: "CMDS/LIBS/Security",      text: "Trusted Execution",                     value: "TRST" },
       { group: "CMDS/LIBS/Security",      text: "Tzset/localtime for Olsen TZ",          value: "TZSE" },
       { group: "HACMP",                   text: "HACMP",                                 value: "HACM" },
       { group: "HACMP",                   text: "Cluster Aware AIX",                     value: "HCAA" },
       { group: "Install",                 text: "Install",                               value: "INST" },
       { group: "Install",                 text: "alt_disk",                              value: "ALTD" },
       { group: "Install",                 text: "emgr/epkg",                             value: "EMGR" },
       { group: "Install",                 text: "geninstall",                            value: "GENI" },
       { group: "Install",                 text: "install/mkinstallp",                    value: "MKIN" },
       { group: "Install",                 text: "lppmgr",                                value: "LPPM" },
       { group: "Install",                 text: "mksysb",                                value: "MKSY" },
       { group: "Install",                 text: "multibos",                              value: "MBOS" },
       { group: "Install",                 text: "nim",                                   value: "NIM"  },
       { group: "Install",                 text: "nimadm",                                value: "NIMA" },
       { group: "Install",                 text: "restvg/savevg",                         value: "REST" },
       { group: "Install",                 text: "rpm",                                   value: "RPM"  },
       { group: "Install",                 text: "wpar",                                  value: "IWPR" },
       { group: "JAVA for AIX",            text: "JAVA for AIX",                          value: "JAVA" },
       { group: "Kernel",                  text: "Kernel",                                value: "KERN" },
       { group: "Kernel",                  text: "Filesystems",                           value: "FSYS" },
       { group: "Kernel",                  text: "Loader/Linker/Assembler",               value: "LLAR" },
       { group: "Kernel",                  text: "LVM",                                   value: "LVM"  },
       { group: "Kernel",                  text: "RAS",                                   value: "RAS"  },
       { group: "Kernel",                  text: "Sysproc",                               value: "SYSP" },
       { group: "Kernel",                  text: "VMM",                                   value: "VMM"  },
       { group: "Networking",              text: "Networking",                            value: "NETW" },
       { group: "Networking",              text: "Crypto",                                value: "CRYP" },
       { group: "Networking",              text: "Network device drivers",                value: "NWDD" },
       { group: "Networking",              text: "NFS",                                   value: "NFS"  },
       { group: "Networking",              text: "Streams",                               value: "STRE" },
       { group: "Networking",              text: "TCP application",                       value: "TCPA" },
       { group: "Networking",              text: "TCP kernel",                            value: "TCPK" },
       { group: "Networking",              text: "TTY",                                   value: "TTY"  },
       { group: "Storage device drivers",  text: "Storage device drivers",                value: "STDD" },
       { group: "Storage device drivers",  text: "CDROM driver",                          value: "CDRD" },
       { group: "Storage device drivers",  text: "Configuration methods",                 value: "CFGM" },
       { group: "Storage device drivers",  text: "FC adapter driver",                     value: "FCAD" },
       { group: "Storage device drivers",  text: "FC disk driver",                        value: "FCDD" },
       { group: "Storage device drivers",  text: "FC tape driver",                        value: "FCTD" },
       { group: "Storage device drivers",  text: "FCOE",                                  value: "FCOE" },
       { group: "Storage device drivers",  text: "MPIO",                                  value: "MPIO" },
       { group: "Storage device drivers",  text: "SCSI disk driver",                      value: "SCDD" },
       { group: "Storage device drivers",  text: "SISRAID driver",                        value: "SISR" },
       { group: "Storage device drivers",  text: "SISSAS adapter driver",                 value: "SISA" },
       { group: "Storage device drivers",  text: "USB driver",                            value: "USBD" },
       { group: "Storage device drivers",  text: "Other storage device drivers",          value: "OTHS" },
       { group: "UI/DIAG",                 text: "UI/DIAG",                               value: "UIDI" },
       { group: "UI/DIAG",                 text: "DIAG",                                  value: "DIAG" },
       { group: "UI/DIAG",                 text: "Globalization/NLS",                     value: "NLS"  },
       { group: "UI/DIAG",                 text: "Graphics device drivers",               value: "GRAP" },
       { group: "UI/DIAG",                 text: "GraPHIGS",                              value: "PHIG" },
       { group: "UI/DIAG",                 text: "Inventory Scout",                       value: "ISCT" },
       { group: "UI/DIAG",                 text: "OpenGL",                                value: "OPGL" },
       { group: "UI/DIAG",                 text: "Pconsole",                              value: "PCON" },
       { group: "UI/DIAG",                 text: "Smitty",                                value: "SMIT" },
       { group: "UI/DIAG",                 text: "Websm",                                 value: "WEBS" },
       { group: "UI/DIAG",                 text: "Xclients",                              value: "XCLI" },
       { group: "UI/DIAG",                 text: "Xserver",                               value: "XSER" },
       { group: "VIOS",                    text: "VIOS",                                  value: "VIOS" },
       { group: "VIOS",                    text: "AMS (Active Memory Sharing)",           value: "AMS"  },
       { group: "VIOS",                    text: "CAA (Cluster Aware AIX)",               value: "VCAA" },
       { group: "VIOS",                    text: "IVM",                                   value: "IVM"  },
       { group: "VIOS",                    text: "LPM",                                   value: "LPM"  },
       { group: "VIOS",                    text: "MKSYSPLAN",                             value: "MKSP" },
       { group: "VIOS",                    text: "NPIV",                                  value: "NPIV" },
       { group: "VIOS",                    text: "padmin CLI commands",                   value: "PCLI" },
       { group: "VIOS",                    text: "SEA",                                   value: "SEA"  },
       { group: "VIOS",                    text: "SSP (Shared Storage Pool)",             value: "SSP"  },
       { group: "VIOS",                    text: "VFC device driver",                     value: "VFCD" },
       { group: "VIOS",                    text: "VSCSI",                                 value: "VSCS" },
       { group: "VIOS",                    text: "VSCSI device driver",                   value: "VSDD" },
       { group: "VIOS",                    text: "Other VIOS related",                    value: "OVIO" },
       { group: "WPAR",                    text: "WPAR",                                  value: "WPAR" },
       { group: "Performance Issue",       text: "Performance Issue",                     value: "PERF" },
       { group: "Non-AIX issue",           text: "Non-AIX issue",                         value: "OTH"  }
      ]
  end
end
