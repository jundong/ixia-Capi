namespace eval IxiaCapi {
    #variable gResultEnable   0
   
    #定义输出调试信息开关
    #--------------------
    variable gDebugEnable    1 ;#enable debug, depends on gOutput
    variable gOutput         "stdout" ;#stdout/log/all
    variable gLogFile        "log.txt"
    #variable gOffline        1
    global  ::gOffline        0
    global ::SUCCESS 1
   
   
    #capture file direction
    variable gSavePath
    #set gSavePath d:/cathy/bb.cap
    set gSavePath ""
    variable logPath
   
    for { set index 0 } { $index < 255 } { incr index } {
        set errorcode($index) $index
    }
    set codemessage [ list "success" \
                          "Bad argument(s)" \
                          "Conflicting argument(s)" \
                          "Missing argument(s)" \
                          "Invalid object(s)" \
                          "Option/Function/Parameter(s) not supportted" \
                          "Disrelated operation(s)" \
                          "Hardware/Tester error" \
                          "Incompatible state" \
                          "Limitation violated" \
                          "Time expired" \
                          "Switch off" \
                          "Partially fail" \
                          ]
   
    array set ASCIIMap [ list \
                       /	2f \
                       0	30 \
                       1	31 \
                       2	32 \
                       3	33 \
                       4	34 \
                       5	35 \
                       6	36 \
                       7	37 \
                       8	38 \
                       9	39 \
                       @	40 \
                       A	41 \
                       B	42 \
                       C	43 \
                       D	44 \
                       E	45 \
                       F	46 \
                       G	47 \
                       H	48 \
                       I	49 \
                       J	4a \
                       K	4b \
                       L	4c \
                       M	4d \
                       N	4e \
                       O	4f \
                       P	50 \
                       Q	51 \
                       R	52 \
                       S	53 \
                       T	54 \
                       U	55 \
                       V	56 \
                       W	57 \
                       X	58 \
                       Y	59 \
                       Z	5a \
                       a	61 \
                       b	62 \
                       c	63 \
                       d	64 \
                       e	65 \
                       f	66 \
                       g	67 \
                       h	68 \
                       i	69 \
                       j	6a \
                       k	6b \
                       l	6c \
                       m	6d \
                       n	6e \
                       o	6f \
                       p	70 \
                       q	71 \
                       r	72 \
                       s	73 \
                       t	74 \
                       u	75 \
                       v	76 \
                       w	77 \
                       x	78 \
                       y	79 \
                       z	7a \
                       ]
   
    set true 1
    set TRUE 1
    set false 0
    set FALSE 0
    set success 0
    set SUCCESS 0
    set fail 1
    set FAIL 1
    set enable 1
    set ENABLE 1
    set disable 0
    set DISABLE 0
    set on 1
    set ON 1
    set off 0
    set OFF 0
    set yes 1
    set YES 1
    set no 0
    set NO 0
   
    set k *1000
    set K *1000
    set m *1000000
    set M *1000000
    set g *1000000000
    set G *1000000000
   
    set ms  *0.001
    set sec *1
    set min *60
    set hour *3600
   
   #set logPath "c:/Tcl/lib/AgtCAPIv1/log.txt" ;# the path for saving log
   #set logPath [file dirname [info script]]/log.txt ;# to save the log in current path
    set timeVal  [ clock format [ clock seconds ] -format %Y%m%d_%H_%M ]
    set filedir [file dirname [info script]]
    if { [file exist "$filedir/ixlogfile"] } {
        set logPath "$filedir/ixlogfile/$timeVal.txt"
    } elseif { [file exist "$filedir/ixlogfile"] } {
        set logPath "$filedir/ixlogfile/$timeVal.txt"
    } else {
        if { [ catch {
            file mkdir "$filedir/ixlogfile"
            set logPath "$filedir/ixlogfile/$timeVal.txt"
        } ] } {
            file mkdir "$filedir/ixlogfile"
            set logPath "$filedir/ixlogfile/$timeVal.txt"
        }
    }
    
    set ResetSessionClass [ list \
                           TestDevice      \
                           TestPort        \
                           ETHPort         \
                           VlanSubInt      \
                           POSPort         \
                           ATMPort         \
                           AtmSubInt       \
                           TrafficEngine   \
                           Host            \
                           Profile         \
                           Stream          \
                           Filter          \
                           TestStatistic   \
                           TestAnalysis    \
                           Pdu             \
                           HeaderCreator   \
                           PacketBuilder   \
                           AgtTestDevice   \
                           AgtTestPort     \
                           AgtTrafficEngine        \
                           AgtStatisticEngine      \
                           BgpV4Router     \
                           BgpRouteBlock   \
                           Ospfv2TopGrid   \
                           Ospfv2TopRouter         \
                           Ospfv2TopGridRouter     \
                           Ospfv2TopNetwork        \
                           Ospfv2TopLink           \
                           Ospfv2TopSummaryBlock   \
                           Ospfv2TopExtBlock       \
                           Ospfv2RouterLsa         \
                           Ospfv2NetworkLsa        \
                           Ospfv2ASExtLsa          \
                           Ospfv2SummaryLsa        \
                           Ospfv2TeRouterLsa       \
                           Ospfv2TeLinkLsa         \
                           Ospfv2Router            \
                           IsisRouter              \
                           IsisGrid                \
                           IsisGridRouter          \
                           IsisTopRouter           \
                           IsisTopNetwork          \
                           IsisRouteBlock          \
                           IsisRouterLink          \
                           RipRouter               \
                           RipRouteBlock           \
                           LdpRouter               \
                           LdpLspPool              \
                           LdpIngressLspPool       \
                           LdpEgressLspPool        \
                           RsvpRouter              \
                           RsvpTunnel              \
                           RsvpEgressTunnel        \
                           RsvpIngressTunnel       \
                           MplsVpn                 \
                           VpnRouteBlock           \
                           PimRouterGroupPool      \
                           pimRpMap                \
                           PimRouter               \
                           IgmpRouterGroupPool     \
                           IgmpRouter              \
                           IgmpHostGroupPool       \
                           IgmpHost                \
                           IGMPClient           \
                           DhcpClient		    \
                           DHCPClient          \
                           DHCPv6Client        \
                           DHCPv4Client        \
                           DhcpRelay		    \
                           DhcpServer		    \
                           Dhcpv4Server		    \
                           Dhcpv6Server		    \
                           DHCPv4Server		    \
                           DHCPv6Server		    \
                           PPPoEClient		    \
                           PPPoEv4Client        \
                           PPPoEv6Client        \
                           PPPoEv4v6Client        \
                           PPPoEServer		    \
                           PPPoEv4Server		    \
                           PPPoEv6Server		    \
                           PPPoEv4v6Server		    \
                           PPPoL2TP		    \
                           IGMPoPPPoE              \
                           IGMPoDHCP               \
						   BgpSession       \
						   OspfSession    \
						   Ospfv2Session    \
                           SimulatedRouter  \
                           IsisSession    \
                           SimulatedRoute  \
                           SimulatedLink   \
						   RouteBlock     \
                           Dhcpv4Host       \
                           Dhcpv6Host       \
                           DhcpHost       \
                           IPoEHost       \
                           Ipv6AutoConfigHost \
                           IPv6SLAACClient   \
                           IgmpHost       \
                           MulticastGroup   \
                           IgmpOverDhcpHost  \
                           MldHost       \
                           MLDHost     \
                           PppoeHost   \
                           Pppoev6Host   \
                           Pppoev4v6Host   \
                           Pppoev4Server   \
                           Pppoev6Server   \
                           Pppoev4v6Server  \
                           802Dot1xClient ]
   
   
    set RetryConnection $on
    set ConnectRetries 3 ;# the retry times of auto connection
    set ConnectDefaultSession $off ;# the switch to connect to default session when no more specific infos are met
    set CheckUserPermit $off ;# the switch to check the permition of user
    set ErrOutPut $on
    set CheckDhcpClientAddress $off ;# the check of address conflict in DHCP emulation
    set WaitTimeout 180
    set RecoverMediatype 1 ;# the switch of media type to which reset session recover
    set PeriodicallyCleanupCount	30
    proc ResetPCFlag {} {
        variable PeriodicallyCleanupCount
        set PeriodicallyCleanupCount	30
    }
   
    #set DefaultHost 168.1.12.100   ;# obsoleted, replced with [ AgtInvoke AgtGetServerHostname ]
    set DefaultTrafficType Constant
    set DefaultTrafficMode CONTINUOUS
    set DefaultTrafficLoad 10
    set DefaultTrafficLoadUnit PERCENT
    set DefaultTrafficBurstSize 1000
    set DefaultFrameLen 128
   
    set MaxTrafficLoad 999999
    set MaxFrameLen 999999    
   
    set Debug 0
    set DebugLog 1
    proc Deputs { value } {
        
        if { $IxiaCapi::Debug } {
            set timeVal  [ clock format [ clock seconds ] -format %T ]
            set clickVal [ clock clicks ]
            puts "\[TIME:$timeVal\]$value"
        }
        if { $IxiaCapi::DebugLog } {
            IxiaCapi::Logger::LogIn -message $value
        }
    }
    proc IxDebugOn { { log 1 } } {
        set IxiaCapi::Debug 1
        set IxiaCapi::DebugLog $log
    }
    proc IxDebugOff { } {
        set IxiaCapi::Debug 0
    }
}

