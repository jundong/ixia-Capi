#====================================================================
# �汾�ţ�1.0
#   
# �ļ�����Ixia_CIsisRouter.tcl
# 
# �ļ�������IxiaCapi����ISIS·����
# 
# ���ߣ�Roger Yang
#
# ����ʱ��: 2009.03.05
#
# �޸ļ�¼�� 
#   
# ��Ȩ���У�Ixia
#====================================================================

#====================================================================
# ������:                                                           
#    ::IsisRouter    By Roger Yang                                           
# ����:                                                               
#    ����Ϊ���࣬�������о���˿ڵĹ�ͬ���� 
#    ���ࣺ��                                                       
#    ���ࣺ����Ķ˿��࣬������̫���˿��ࡢ������·�˿����                                                      
#    ����ࣺЭ������ࡢ���������������ͳ�Ʒ���������                                         
# �﷨����:                                                         
#    TestDevice ipaddress                                           
#    �磺TestDevice Tester1 192.168.0.100                           
#====================================================================

namespace eval IxiaCapi {
    
itcl::class IsisRouter {
    namespace import ::IxiaCapi::*

    public variable m_portObjectId    ""    
    public variable m_chassisId       "192.168.1.100"
    public variable m_slotId          "2"
    public variable m_portId          "1"
    public variable m_vportId         ""
    public variable m_routerType      ""
    public variable m_routerId        ""
    public variable m_this            ""
    public variable m_namespace       ""
    public variable m_bgpId           ""
    public variable m_intfId          ""
    public variable m_intfIdList      ""
    public variable m_intfIpv4Id      ""
    public variable m_intfMac         "00 00 00 00 00 01"
    public variable m_intfv4Ip        "20.3.17.2"
    public variable m_intfv4IpMask    "24"
    public variable m_intfv4Gateway   "20.3.17.1"
    public variable m_neighborRange_parameter_default() ""
    public variable m_sg_neighborRange ""
    public variable m_isisRouter ""
    public variable m_routerName ""
    public variable m_isisBlockArray
    public variable m_ixRouterId       ""
    public variable m_isisRouterInterface ""
    public variable m_isisGridArray
    public variable m_flapRouteBlockTimerList ""
    public variable m_flapRouterTimerList ""
    public variable m_isisTopRouterParaArray 
    public variable m_isisIPToInterFaceID 
    public variable m_isisRTNameToInterFaceID

    
    inherit Router
    constructor {portobj routertype routerid } \
    {Router::constructor $portobj $routertype $routerid} {

        set m_portObjectId $portobj
        set m_chassisId [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_chassisId]
        set m_slotId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_slotId]
        set m_portId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_portId]
        set m_vportId   [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_vportId]
        set m_routerType $routertype
        set m_routerId  $routerid
        set m_this      [namespace tail $this]
        set m_namespace [namespace qualifiers $this]
        set IxiaCapi::namespaceArray($m_this,namespace) $m_namespace

        #�����ǻ�ȡ vport/Interface�Ķ���,���Interface�ںܶ�ط���Ҫ�õ�,����ָ��·����ʹ���ĸ�Interface.һ��
        #�ӿ��Ͽ��Խ������Interfaces,���Ի���Ҫ�ο�Shawn�Ĵ�������޸�.
        #set m_intfId [lindex [ixNet getList $m_vportId interface] 0]
        #puts "m_intfId  '$m_intfId'"
        set m_intfIdList [ixNet getList $m_vportId interface]
        #puts "m_intfIdList: $m_intfIdList"

        ixNet setAttribute $m_vportId/protocols/isis -enabled True
        set m_ixRouterId [ixNet add $m_vportId/protocols/isis router]
        ixNet setAttribute $m_ixRouterId -enabled True
        ixNet commit
        set m_ixRouterId [ixNet remapIds $m_ixRouterId]        
    }

    
    
    destructor {
    }
    
    ;#��������Ҫʵ�ֵķ���,�������API.
    public method ConfigRouter
    public method GetRouter
    public method Enable
    public method Disable
    public method AddGrid
    public method ConfigGrid
    public method RemoveGrid
    
    #����8������Ϊ��һ���ֳ����պ����ZTEҪ�������ĺ���
    #################################################
    public method AddTopRouter
    public method ConfigTopRouter
    public method AddTopRouterLink
    public method ConfigTopRouterLink
    public method AddTopNetwork
    public method ConfigTopNetwork
    public method RemoveTopNetwork
    public method RemoveTopRouter
    #################################################
    
    
    public method CreateRouteBlock
    public method ConfigRouteBlock
    public method GetRouteBlock    
    public method DeleteRouteBlock
    public method ListRouteBlock
    public method AdvertiseRouteBlock
    public method WithdrawRouteBlock
    public method ConfigFlap
    public method StartFlapRouters
    public method StopFlapRouters
    public method ConfigFlapRouteBlock
    public method StartFlapRouteBlock   
    public method StopFlapRouteBlock
    public method GetRouterStats
    public method GraceRestartAction
    public method CheckEssentialArgs 
    public method AdvertiseRouters  ;# �������Ixia��֧��
    public method WithdrawRouters   ;# �������Ixia��֧��
    public method StartISISRouter ;# ���������CAPI����,��Roger�Լ�������ΪDebug����.
    public method StopISISRouter  ;# ���������CAPI����,��Roger�Լ�������ΪDebug����.
}

#PASS
#====================================================================
# ��������:ConfigRouter by Roger 2009.3
# ������д: ��׿ 
# ��������:����Isis Router
#
# �������:
# ��������              ����˵��                ��������       Ixia֧��
#AddressFamily	        IPv4 ��IPV6 �� both	��ѡ           ֧��
# ����4��������������,��Ϊ�ڱ���������Ҫʹ��IP��ַ���ж�ʹ����һ���ӿ�.
#IpV4Addr	        Isis Router��IP��ַ�� 	��ѡ           ֧��
#IpV4PrefixLen	        IP��ַ��ǰ׺����                       ֧��
#IPV6Addr	        Isis Router��Ipv6��ַ	��ѡ           ֧��
#IpV6PrefixLen	        IP��ַ��ǰ׺����	��ѡ           ֧��
#AreaId	                ����ID	    ��ѡ                       ֧��
#                       ����: "49 00 01" Ҫ������.
#SystemId	        ϵͳID	                ��ѡ           ֧��
#                       ����: "5E 1C 00 01 00 00" Ҫ������
#RouterId	        ��������routerID	��ѡ           ֧��
#FlagWideMetric 	�Ƿ�֧�ֿ����	��ѡ                   ֧��,��TEѡ����.
#FlagThree-wayHandshake	�Ƿ�֧��Three-way����	��ѡ           
#FlagRestartHelper 	�Ƿ�֧��GRHelper	��ѡ           ֧��,��HitlessRestart��.
#                       ����: True/false     
#FlagDropSutLsp	        �Ƿ�����������SUT������LSP	��ѡ   ֧��,
#FlagMultiTopology	�Ƿ�֧�ֶ�����	��ѡ                   ��֧�� 
#HoldTimer	        �ھӱ���ʱ��	��ѡ                   ֧��
#IihInterval	        IIH�ķ���ʱ����,����Hello���ļ��	��ѡ      ֧��
#CsnpInterval	        CSNP�ķ���ʱ����	��ѡ           ��֧��
#PsnpInterval	        PSNP�ķ���ʱ����	��ѡ           ��֧��
#MaxPacketSize	        ���ݰ���󳤶�	��ѡ                    ֧��, ��Max LSP Size, ��general������,���1497
#L2RouterPriority	L2·���������ȼ�	��ѡ            �ݲ�֧�� ֻ�� ��Interfaces�µ�Advanced Interfaces settings
#L1RouterPriority	L1·���������ȼ�	��ѡ            �ݲ�֧�� ֻ��
#RoutingLevel	        ·�����Ĳ��	��ѡ                    ֧��   �������is-type
##                      ����: 1 , 2 , 1+2 ��level1 , level2, level1+2
#AreaId1 	        ����ID	��ѡ                            ������ ��Area Address,��Advanced Routing Settings�е� Areaѡ��.
#AreaId2	        ����ID	��ѡ                            ������
#Active	                ��Э����湦��enable or disable	��ѡ    ֧��
#                        ����Ҫ��,����RouterĬ��״̬��������Disable��,���Ҫ����,�����ʹ��Enable����,�������û�
#                       ConfigRouter��ʱ���������������Enable����Disable,���ﶼ��Disable.
#GRT1Interval        	GR����T1��ʱ��	��ѡ                    ��֧��
#GRT2Interval	        GR����T2��ʱ��	��ѡ                    ��֧��
#GRT3Interval	        GR����T3��ʱ��	��ѡ                    ��֧��
#LevelGRT1	        GR T1���ڲ��	��ѡ                    ��֧��
#LevelGRT2	        GR T2���ڲ��	��ѡ                    ��֧��
#LevelGRT3	        GR T3���ڲ��	��ѡ                    ��֧��
#AuthType	        ��֤���͡����ĸ�ö�����������£� (1)NO_AUTHENTICATION (2)LINK_AUTHENTICATION (3)AREA_AUTHENTICATION
#                       (4)DOMAIN_AUTHENTICATION	��ѡ    ֧��, LINK_AUTHENTICATION����Ixia�Ľӿ��µ�Circuit Authentication.
#FlagL1IIHAuth	        ��1IIH������֤	��ѡ                     
#FlagL2IIHAuth	        ��2IIH������֤	��ѡ
#FlagL1LSPAuth	        ��1LSP������֤	��ѡ
#FlagL2LSPAuth	        ��2LSP������֤	��ѡ
#FlagSNPAuth	        SNP������֤	��ѡ
#FlagGatewayAdd	        �Ƿ�֧������	��ѡ
#FlagTE	                ���� FlagTe��������Ĭ������£�Ӧ���ǲ�������TE���ܵģ���ΪTE����ֻ��Metric����Ϊwideʱ����Ч	��ѡ
#		        ��ѡ   ֧��
#                        ����: True/False
#
#Metric	                �ӿڵ�costֵ��FlagWideMetric ֵ��� 	��ѡ  ֧��, ��IxN�µ�Interface Metric
#                       ����: 10
#AuthPassword	        ISIS ��ʵ������֤	��ѡ
#AuthPasswordIIh	ISIS hello������֤	��ѡ
#
#
# �﷨����:                                                         
#    IsisRouter ConfigRouter �CIpAddr 192.1.1.2 �CPrefixLen 24 �CAreaID 00 �CSysID aaaaaaaaaaaa �CLevel L1                                    
# ����ֵ��                                                          
#    �ɹ�0��ʧ��1��                         
#====================================================================
itcl::body IsisRouter::ConfigRouter {args} {
        
    ixDebugPuts "Enter proc IsisRouter::ConfigRouter...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set addressFamily "ipv4"
    set ipv4Addr "20.3.17.2"
    set flagWideMetric "False"
    set holdTimer 0
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]


#������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-addressfamily -ipv4addr -ipv6addr}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }



    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]


    
        case $cmdx      {
             -addressfamily {set addressFamily $argx}             
             -ipv4addr      {set ipv4Addr $argx}
             -ipv4prefixlen {set ipv4PrefixLen $argx}
             -ipv6addr      {set ipv6Addr $argx}
             -ipv6prefixlen {set ipv6PrefixLen $argx}
             -areaid        {set areaId $argx}
             -systemid      {set systemId $argx}
             -flagwidemetric {set flagWideMetric $argx}
             -flagrestarthelper {set flagRestartHelper $argx}
             -flagte        {set flagTe $argx}
             -routerid      {set routerId $argx}
             -flagdropsutlsp {set flagDropSutLsp $argx}
             -holdtimer     {set holdTimer $argx}
             -iihinterval   {set iihInterval $argx}
             -maxpacketsize {set maxPacketSize $argx}
             -routinglevel  {set routingLevel $argx}
             -active        {set Active $argx}
             -authtype      {set authType $argx}
             -authpassword  {set authPassword $argx}
             -metric        {set Metric $argx}
             
             
             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }

        
        
    
    
    set sg_router $m_ixRouterId
    set m_isisIPToInterFaceID($ipv4Addr,RID) $m_ixRouterId
    set routerName $IxiaCapi::tmpRouterObjectName
    set m_isisRTNameToInterFaceID($routerName,RID) $m_ixRouterId
    ixNet setAttribute $sg_router -areaAddressList [list $areaId ]
    ixNet setAttribute $sg_router -areaAuthType none
    ixNet setAttribute $sg_router -areaReceivedPasswordList [list ]
    ixNet setAttribute $sg_router -areaTransmitPassword {}
    ixNet setAttribute $sg_router -domainAuthType none
    ixNet setAttribute $sg_router -domainReceivedPasswordList [list ]
    ixNet setAttribute $sg_router -domainTransmitPassword {}
    if {$authType == "no_authentication"} {    
    } elseif {$authType ==  "area_authentication" } {
            ixNet setAttribute $sg_router -areaAuthType password
            ixNet setAttribute $sg_router -areaReceivedPasswordList [list $authPassword]
            ixNet setAttribute $sg_router -areaTransmitPassword $authPassword
    } elseif {$authType ==  "domain_authentication" } {
            ixNet setAttribute $sg_router -domainAuthType password
            ixNet setAttribute $sg_router -domainReceivedPasswordList [list $authPassword]
            ixNet setAttribute $sg_router -domainTransmitPassword $authPassword
    }



    ixNet setAttribute $sg_router -enableAttached True
    ixNet setAttribute $sg_router -enableAutoLoopback True
    if {$flagDropSutLsp == "false"} {
    ixNet setAttribute $sg_router -enableDiscardLearnedLsps False    
    }

    if {$flagRestartHelper == "true"} {
    ixNet setAttribute $sg_router -enableHitlessRestart True
    ixNet setAttribute $sg_router -restartMode helperRouter 
    ixNet setAttribute $sg_router -restartTime 30 
    ixNet setAttribute $sg_router -restartVersion version4 
    }
    if {$flagTe == "true"} {
    ixNet setAttribute $sg_router -teEnable True 
    ixNet setAttribute $sg_router -teRouterId $routerId    
    }

    ixNet setAttribute $sg_router -enableIgnoreRecvMd5 True
    ixNet setAttribute $sg_router -enableOverloaded False
    ixNet setAttribute $sg_router -enablePartitionRepair False
    if {$flagWideMetric == "true"} {
    ixNet setAttribute $sg_router -enableWideMetric True   
    }
    #����Ҫ��,����RouterĬ��״̬��������Disable��,���Ҫ����,�����ʹ��Enable����,�������û�
    #ConfigRouter��ʱ���������������Enable����Disable,���ﶼ��Disable.
    if {$Active == "true"} {
    ixNet setAttribute $sg_router -enabled True    
    } else {
    ixNet setAttribute $sg_router -enabled False            
    }
    


    ixNet setAttribute $sg_router -lspLifeTime 1200
    ixNet setAttribute $sg_router -lspMaxSize  $maxPacketSize
    ixNet setAttribute $sg_router -lspRefreshRate 900
    ixNet setAttribute $sg_router -maxAreaAddresses 3
    ixNet setAttribute $sg_router -systemId $systemId
    ixNet commit
    set sg_router [lindex [ixNet remapIds $sg_router] 0]
    set ixNetSG_Stack(2) $sg_router

    set m_isisRouter $sg_router

    
    
    #������һ����ΪISIS����һ��·�ɽӿ�,�������·�ɽӿڶ�Ӧ���Ѿ�����ʵ�ʵ�IP Interfaces��ȥ.
    set sg_interface [ixNet add $ixNetSG_Stack(2) interface]
    set m_isisRouterInterface $sg_interface
    if {$authType == "link_authentication" } {
       ixNet setAttribute $sg_interface -circuitAuthType password 
       ixNet setAttribute $sg_interface -circuitReceivedPasswordList  [list $authPassword]
       ixNet setAttribute $sg_interface -circuitTransmitPassword $authPassword
    }         

    ixNet setAttribute $sg_interface -enableAutoAdjustArea True
    ixNet setAttribute $sg_interface -configuredHoldTime $holdTimer
    ixNet setAttribute $sg_interface -enableAutoAdjustMtu True
    ixNet setAttribute $sg_interface -enableConnectedToDut True
    ixNet setAttribute $sg_interface -enabled True
    ##������Ҫ�����û������IPv4/v6�ĵ�ַ���ж�ʹ����һ��Interface.
    if {$addressFamily == "ipv4" } {
        foreach intf $m_intfIdList {
            set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
            if {$ipaddr == $ipv4Addr} {
                puts "Find Ipv4 Interface!!"
                set m_intfId $intf
                ixNet setAttribute $sg_interface -interfaceId $m_intfId
                ixNet commit
                break
            }         
        }
    }

    if {$addressFamily == "ipv6" } {
        foreach intf $m_intfIdList {
            set ipaddr [ixNet getAttribute $intf/ipv6:1 -ip]
            if {$ipaddr == $ipv6Addr} {
                puts "Find Ipv6 Interface!!"
                set m_intfId $intf
                ixNet setAttribute $sg_interface -interfaceId $m_intfId
                ixNet commit
                break
            }         
        }
    }
    
    
    ;#����û�ѡ��ʹ��IPv4�Ľӿ�,������IPv6�Ľӿ���Ϣɾ��.��Ϊ�ڴ���HOST��ʱ��,ͬʱ�ᴴ��IPv6��v4�Ľӿ���Ϣ
    ;# �����û�ѡ��IPv6�Ľӿ���ʹ��,��Ixia���Զ�ѡ��IPv6,�Ͳ���ɾ��IPv4�Ľӿ���.
    if  {$addressFamily == "ipv4"} {
        set v6Int [ixNet getList $m_intfId ipv6]
        ixNet remove $v6Int
        ixNet commit
    }
    
    
    #ixNet setAttribute $sg_interface -interfaceId $m_intfId
    #ixNet setAttribute $sg_interface -interfaceIp 20.3.17.2
    #ixNet setAttribute $sg_interface -interfaceIpMask 255.255.255.0
    if {$routingLevel == 1} {
    ixNet setAttribute $sg_interface -level level1    
    } elseif {$routingLevel == 2} {
    ixNet setAttribute $sg_interface -level level2    
    } else {
    ixNet setAttribute $sg_interface -level level1Level2        
    }

    ixNet setAttribute $sg_interface -level1DeadTime 30
    ixNet setAttribute $sg_interface -level1HelloTime $iihInterval
    ixNet setAttribute $sg_interface -level2DeadTime 30
    ixNet setAttribute $sg_interface -level2HelloTime $iihInterval
    ixNet setAttribute $sg_interface -metric $Metric
    ixNet setAttribute $sg_interface -networkType broadcast
    ixNet commit
    set sg_interface [lindex [ixNet remapIds $sg_interface] 0]

    
} ;# end BgpRouter::ConfigRouter


#====================================================================
# ��������:GetRouter
# ������д: ��׿ 2009.4.20
# ��������: ��ȡIsis Router��������Ϣ, �����û��������ӡÿ����ѡ������ʵ�ʵ�ֵ.
#
# �������:
# ��������              ����˵��                ��������       Ixia֧��
#AddressFamily	        IPv4 ��IPV6 �� both	��ѡ           ֧��
# ����4������ȡ��,��Ϊ��CreateHost���Ѿ������˽ӿ���.
#IpV4Addr	        Isis Router��IP��ַ�� 	��ѡ           ֧��  
#IpV4PrefixLen	        IP��ַ��ǰ׺����                       ֧��
#IPV6Addr	        Isis Router��Ipv6��ַ	��ѡ           ֧��
#IpV6PrefixLen	        IP��ַ��ǰ׺����	��ѡ           ֧��
#AreaId	                ����ID	    ��ѡ                       ֧��
#                       ����: "49 00 01" Ҫ������.
#SystemId	        ϵͳID	                ��ѡ           ֧��
#                       ����: "5E 1C 00 01 00 00" Ҫ������
#RouterId	        ��������routerID	��ѡ           ֧��
#FlagWideMetric 	�Ƿ�֧�ֿ����	��ѡ                   ֧��,��TEѡ����.
#FlagThree-wayHandshake	�Ƿ�֧��Three-way����	��ѡ           
#FlagRestartHelper 	�Ƿ�֧��GRHelper	��ѡ           ֧��,��HitlessRestart��.
#                       ����: True/false     
#FlagDropSutLsp	        �Ƿ�����������SUT������LSP	��ѡ   ֧��,
#FlagMultiTopology	�Ƿ�֧�ֶ�����	��ѡ                   ��֧�� 
#HoldTimer	        �ھӱ���ʱ��	��ѡ                   ֧��
#IihInterval	        IIH�ķ���ʱ����,����Hello���ļ��	��ѡ      ֧��
#CsnpInterval	        CSNP�ķ���ʱ����	��ѡ           ��֧��
#PsnpInterval	        PSNP�ķ���ʱ����	��ѡ           ��֧��
#MaxPacketSize	        ���ݰ���󳤶�	��ѡ                    ֧��, ��Max LSP Size, ��general������,���1497
#L2RouterPriority	L2·���������ȼ�	��ѡ            �ݲ�֧�� ֻ�� ��Interfaces�µ�Advanced Interfaces settings
#L1RouterPriority	L1·���������ȼ�	��ѡ            �ݲ�֧�� ֻ��
#RoutingLevel	        ·�����Ĳ��	��ѡ                    ֧��   �������is-type
##                      ����: 1 , 2 , 1+2 ��level1 , level2, level1+2
#AreaId1 	        ����ID	��ѡ                            ������ ��Area Address,��Advanced Routing Settings�е� Areaѡ��.
#AreaId2	        ����ID	��ѡ                            ������
#Active	                ��Э����湦��enable or disable	��ѡ    ֧��
#GRT1Interval        	GR����T1��ʱ��	��ѡ                    ��֧��
#GRT2Interval	        GR����T2��ʱ��	��ѡ                    ��֧��
#GRT3Interval	        GR����T3��ʱ��	��ѡ                    ��֧��
#LevelGRT1	        GR T1���ڲ��	��ѡ                    ��֧��
#LevelGRT2	        GR T2���ڲ��	��ѡ                    ��֧��
#LevelGRT3	        GR T3���ڲ��	��ѡ                    ��֧��
#AuthType	        ��֤���͡����ĸ�ö�����������£� (1)NO_AUTHENTICATION (2)LINK_AUTHENTICATION (3)AREA_AUTHENTICATION
#                       (4)DOMAIN_AUTHENTICATION	��ѡ    ֧��, LINK_AUTHENTICATION����Ixia�Ľӿ��µ�Circuit Authentication.
#FlagL1IIHAuth	        ��1IIH������֤	��ѡ                     
#FlagL2IIHAuth	        ��2IIH������֤	��ѡ
#FlagL1LSPAuth	        ��1LSP������֤	��ѡ
#FlagL2LSPAuth	        ��2LSP������֤	��ѡ
#FlagSNPAuth	        SNP������֤	��ѡ
#FlagGatewayAdd	        �Ƿ�֧������	��ѡ
#FlagTE	                ���� FlagTe��������Ĭ������£�Ӧ���ǲ�������TE���ܵģ���ΪTE����ֻ��Metric����Ϊwideʱ����Ч	��ѡ
#		        ��ѡ   ֧��
#                        ����: True/False
#
#Metric	                �ӿڵ�costֵ��FlagWideMetric ֵ��� 	��ѡ  ֧��, ��IxN�µ�Interface Metric
#                       ����: 10
#AuthPassword	        ISIS ��ʵ������֤	��ѡ
#AuthPasswordIIh	ISIS hello������֤	��ѡ
#
#
# �﷨����:                                                         
#    isis1 GetRouter -addressfamily  IPv4 -areaid "00 00 01" -systemid "64 01 00 01 00 00"
#                                      
# ����ֵ��                                                          
#    ��ӡÿ����ѡ������ֵ,�籾����Ӧ�ô�ӡ
#   addressfamily is both IPv4 and IPv6
#   areaid is {49 00 01}
#   systemId is 64 01 00 01 00 00
#====================================================================
itcl::body IsisRouter::GetRouter {args} {
        #
        #    puts "BlockName: $blockName"
        #set sg_routeRange $m_isisBlockArray($blockName)        
        #puts "FirstRoute: [ixNet getAttribute $sg_routeRange -firstRoute]"
    ixDebugPuts "Enter proc IsisRouter::GetRouter...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    #�����Ƕ������е�args������,Ȼ���ӡÿ��args��ʵ�ʵ�ֵ.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set value [lindex $args [expr $idxxx + 1]]
        case $cmdx      {
             -addressfamily {
                puts "addressfamily is both IPv4 and IPv6"
                upvar $value arg
                set arg "IPv4/IPv6" 
                }
             -areaid        {
                set areaid [ixNet getAttribute $m_ixRouterId -areaAddressList]
                upvar $value arg
                set arg $areaid
             }
             -systemid      {
                set systemid [ixNet getAttribute $m_ixRouterId -systemId]
                upvar $value arg
                set arg $systemid
             }
             -flagwidemetric {
                set flagwidemetric [ixNet getAttribute $m_ixRouterId -enableWideMetric]
                upvar $value arg
                set arg $flagwidemetric
             } 
             -flagrestarthelper {
                set flagrestarthelper [ixNet getAttribute $m_ixRouterId -enableHitlessRestart]
                upvar $value arg
                set arg $flagrestarthelper
                } 
             -flagte        {
                set flagte [ixNet getAttribute $m_ixRouterId -teEnable]
                upvar $value arg
                set arg $flagte
                } 
             -routerid      {
                set routerid [ixNet getAttribute $m_ixRouterId -teRouterId]
                upvar $value arg
                set arg $routerid
             } 
             -flagdropsutlsp {
               set flagdropsutlsp [ixNet getAttribute $m_ixRouterId -enableDiscardLearnedLsps]
               upvar $value arg
               set arg $flagdropsutlsp            
             } 
             -holdtimer     {
                set holdtimer [ixNet getAttribute $m_isisRouterInterface -configuredHoldTime]
                upvar $value arg
                set arg $holdtimer             
                }
             -iihinterval   {
                set iihinterval [ixNet getAttribute $m_isisRouterInterface -level1HelloTime]
                upvar $value arg
                set arg $iihinterval            
             }
             -maxpacketsize {
                set maxpacketsize [ixNet getAttribute $m_ixRouterId -lspMaxSize]
                upvar $value arg
                set arg $maxpacketsize
             }
             -routinglevel  {
                set routinglevel [ixNet getAttribute $m_isisRouterInterface -level]
                upvar $value arg
                set arg $routinglevel
             }
             -active        {
                set active [ixNet getAttribute $m_ixRouterId -enabled]
                upvar $value arg
                set arg $active
            }
             -authtype      {
                set authtype [ixNet getAttribute $m_ixRouterId -areaAuthType]
                upvar $value arg
                set arg $authtype
             }
             -authpassword  {
                set authpassword [ixNet getAttribute $m_ixRouterId -areaReceivedPasswordList]
                upvar $value arg
                set arg $authpassword
             }
             -metric        {
                set metric [ixNet getAttribute $m_isisRouterInterface -metric]
                upvar $value arg
                set arg $metric
             }
             default     {
                          puts "Error : No such option, please check input"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
}


#====================================================================
# ��������: Enable  
# ������д: ��׿  Roger 2009.3.23
# ����: ʹ��ָ���� ISIS Router
# ����: 
#
# �﷨����:                                                         
#
#   isis1 Enable
#
# ����ֵ��  ��
# 
#====================================================================
itcl::body IsisRouter::Enable {args} {
    
    ixDebugPuts "Enter proc IsisRouter::Enable...\n"
    ixNet setAttribute $m_ixRouterId -enabled True
    ixNet commit
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
    return $::SUCCESS 
}

#====================================================================
# ��������:Disable
# ������д: ��׿  2009.3.23
# ��������: ����ָ����ISIS Router
# �������:
# �﷨����:                                                         
#      isis Disable
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::Disable {args} {
    ixDebugPuts "Enter proc IsisRouter::Disable...\n"
    ixNet setAttribute $m_ixRouterId -enabled False
    ixNet commit
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
    return $::SUCCESS 
}



#ͨ�� 2008-4-17
#====================================================================
# ��������:AddGrid
# ������д: ��׿ 2009.3.24
# ��������: Ϊָ����ISIS Router����ISIS�������ˣ�
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# GridName	ISIS Grid�����Ʊ�ʶ��            ��ѡ                  ֧��
#                Ҫ��ÿISIS�ھ�Ψһ�� 	         ��ѡ	     ��        ��֧��
# GridRows	ģ���ISIS Grid��������	         ��ѡ	     1         ֧��
# GridCols	ģ���ISIS Grid��������	         ��ѡ	     1         ֧��
# StartingRouterId	�ʼ��RouterID��	 	               ֧��
#                    ����: {99 00 00 00 00 00 } ���� "99 00 00 00 00 00"
# StartingSystemId	�ʼ��SystemID��		               ��֧��
# FlagAdvetisted	�㲥��ʽ(���Ƿ�㲥)		                ֧��
# FlagTe	֧����������		                               ֧��
# MultiTopology	֧�ֶ�����		                               ֧�� 
# RoutingLevel	·�������		                               ?�Ƿ�ҪIsType����ʲô��˼?
# AddressFamily	 Ixia�²�:Ӧ���ǹ㲥��·�ɵ�����IPv4��v6.               ֧��	
#                ����: ipv4, ipv6
# Ixia�����������²���:
# StartIP        ���������Grid�е�һ��IP��ַ. Ĭ��: 200.1.1.1
# StartIPMask    ���������Grid�е�һ��IP��ַ�����볤��, Ĭ��: 24
# �﷨����:                                                         
#      isis AddGrid 
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::AddGrid {args} {
    ixDebugPuts "Enter proc IsisRouter::AddGrid...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set gridName grid1
    set flagAdvetisted "false"
    set gridRows 1
    set gridCols 1
    set startIp 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-gridname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -gridname      {set gridName $argx}
             -gridcols      {set gridCols $argx}
             -gridrows      {set gridRows $argx}
             -startingrouterid      {set startingRouterId $argx}
             -flagadvetisted      {set flagAdvetisted $argx}
             -flagte        {set flagTe $argx}
             -routinglevel  {set routingLevel $argx}
             -addressfamily {set addressFamily $argx}
             -startip       {set startIp $argx}
             -startipmask   {set startIpMask $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }

    set sg_networkRange [ixNet add $m_ixRouterId networkRange]
    set m_isisNetworkRange $sg_networkRange
    set m_isisGridArray($gridName) $sg_networkRange
     if {$flagAdvetisted == "true"} {
        ixNet setAttribute $sg_networkRange -enabled True
     } else {
        ixNet setAttribute $sg_networkRange -enabled False
     }
     
     ixNet setAttribute $sg_networkRange -entryCol 1 
     ixNet setAttribute $sg_networkRange -entryRow 1
     ixNet setAttribute $sg_networkRange -gridNodeRoutes  {  }
     ixNet setAttribute $sg_networkRange -gridOutsideLinks  {  }
     ixNet setAttribute $sg_networkRange -interfaceIps  [list [list $addressFamily $startIp $startIpMask] ]
     ixNet setAttribute $sg_networkRange -interfaceMetric 1
     ixNet setAttribute $sg_networkRange -linkType broadcast ;#pointToPoint
     ixNet setAttribute $sg_networkRange -noOfCols $gridCols
     ixNet setAttribute $sg_networkRange -noOfRows $gridRows
     ixNet setAttribute $sg_networkRange -routerId $startingRouterId
     ixNet setAttribute $sg_networkRange -routerIdIncrement {00 00 00 00 00 01 }
     ixNet setAttribute $sg_networkRange -tePaths  {  }
     ixNet setAttribute $sg_networkRange -useWideMetric False
     
    if {$flagTe == "true"} {
        ixNet setMultiAttrs $sg_networkRange/entryTe \
         -enableEntryTe True \
         -eteAdmGroup {00 00 00 00} \
         -eteLinkMetric 0 \
         -eteMaxBandWidth 0 \
         -eteMaxReserveBandWidth 0 \
         -eteRouterId 0.0.0.1 \
         -eteRouterIdIncrement 0.0.0.1 \
         -eteUnreservedBandWidth {0 0 0 0 0 0 0 0}
        ixNet setMultiAttrs $sg_networkRange/rangeTe \
         -enableRangeTe True \
         -teAdmGroup {00 00 00 00} \
         -teLinkMetric 0 \
         -teMaxBandWidth 0 \
         -teMaxReserveBandWidth 0 \
         -teRouterId 0.0.0.1 \
         -teRouterIdIncrement 0.0.0.1 \
         -teUnreservedBandWidth {0 0 0 0 0 0 0 0}          
    }

    ixNet commit
    

    set sg_networkRange [lindex [ixNet remapIds $sg_networkRange] 0]
    puts "Fininshed!"
    #set sg_networkRange [lindex [ixNet remapIds $sg_networkRange] 0]
}




#
#====================================================================
# ��������:ConfigGrid  
# ������д: ��׿ 2009.3.30
# ��������: Ϊָ����ISIS Router  �޸��Ѿ����ڵ�ISIS�������ˣ�
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# GridName	ISIS Grid�����Ʊ�ʶ��
#                Ҫ��ÿISIS�ھ�Ψһ�� 	         ��ѡ	     ��        ��֧��
# GridRows	ģ���ISIS Grid��������	         ��ѡ	     1         ֧��
# GridCols	ģ���ISIS Grid��������	         ��ѡ	     1         ֧��
# StartingRouterId	�ʼ��RouterID��	 	               ֧��
#                    ����: {99 00 00 00 00 00 } ���� "99 00 00 00 00 00"
# StartingSystemId	�ʼ��SystemID��		               ��֧��
# FlagAdvetisted	�㲥��ʽ(���Ƿ�㲥)	 	                ֧��       
# FlagTe	֧����������		                               ֧��
# MultiTopology	֧�ֶ�����		                               ֧�� 
# RoutingLevel	·�������		                               ?�Ƿ�ҪIsType����ʲô��˼?
# AddressFamily	 Ixia�²�:Ӧ���ǹ㲥��·�ɵ�����IPv4��v6.               ֧��	
#                ����: ipv4, ipv6
# Ixia�����������²���:
# StartIP        ���������Grid�е�һ��IP��ַ. Ĭ��: 200.1.1.1
# StartIPMask    ���������Grid�е�һ��IP��ַ�����볤��, Ĭ��: 24
# �﷨����:                                                         
#      isis1 ConfigGrid -gridname "grid1" -flagadvetisted "true" -gridcols 3 -gridrows 3 -startingrouterid {00 00 00 88 88 00} -startip 188.1.1.1 -startIpMask 16 \
#                       -addressFamily IPV4  -flagte "false"   
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::ConfigGrid {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigGrid...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set gridname ""
    set flagAdvetisted "false"
    set gridRows 1
    set gridCols 1
    set startIp 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-gridname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    
    
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -gridname      {set gridName $argx}
             -gridcols      {set gridCols $argx}
             -gridrows      {set gridRows $argx}
             -startingrouterid      {set startingRouterId $argx}
             -flagadvetisted      {set flagAdvetisted $argx}
             -flagte        {set flagTe $argx}
             -routinglevel  {set routingLevel $argx}
             -addressfamily {set addressFamily $argx}
             -startip       {set startIp $argx}
             -startipmask   {set startIpMask $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    
    
    #set sg_networkRange $m_isisNetworkRange
     set sg_networkRange $m_isisGridArray($gridName)
     if {$flagAdvetisted == "true"} {
        ixNet setAttribute $sg_networkRange -enabled True
     } else {
        ixNet setAttribute $sg_networkRange -enabled False
        
     }
     
     ixNet setAttribute $sg_networkRange -entryCol 1 
     ixNet setAttribute $sg_networkRange -entryRow 1
     ixNet setAttribute $sg_networkRange -gridNodeRoutes  {  }
     ixNet setAttribute $sg_networkRange -gridOutsideLinks  {  }
     ixNet setAttribute $sg_networkRange -interfaceIps  [list [list $addressFamily $startIp $startIpMask] ]
     ixNet setAttribute $sg_networkRange -interfaceMetric 1
     ixNet setAttribute $sg_networkRange -linkType pointToPoint
     ixNet setAttribute $sg_networkRange -noOfCols $gridCols
     ixNet setAttribute $sg_networkRange -noOfRows $gridRows
     ixNet setAttribute $sg_networkRange -routerId $startingRouterId
     ixNet setAttribute $sg_networkRange -routerIdIncrement {00 00 00 00 00 01 }
     ixNet setAttribute $sg_networkRange -tePaths  {  }
     ixNet setAttribute $sg_networkRange -useWideMetric false
     
    if {$flagTe == "true"} {
        ixNet setMultiAttrs $sg_networkRange/entryTe \
         -enableEntryTe True \
         -eteAdmGroup {00 00 00 00} \
         -eteLinkMetric 0 \
         -eteMaxBandWidth 0 \
         -eteMaxReserveBandWidth 0 \
         -eteRouterId 0.0.0.1 \
         -eteRouterIdIncrement 0.0.0.1 \
         -eteUnreservedBandWidth {0 0 0 0 0 0 0 0}
        ixNet setMultiAttrs $sg_networkRange/rangeTe \
         -enableRangeTe True \
         -teAdmGroup {00 00 00 00} \
         -teLinkMetric 0 \
         -teMaxBandWidth 0 \
         -teMaxReserveBandWidth 0 \
         -teRouterId 0.0.0.1 \
         -teRouterIdIncrement 0.0.0.1 \
         -teUnreservedBandWidth {0 0 0 0 0 0 0 0}          
    }

    ixNet commit
    set sg_networkRange [lindex [ixNet remapIds $sg_networkRange] 0]
    puts "Fininshed!"
    
}


#ͨ��
#====================================================================
# ��������:RemoveGrid  
# ������д: ��׿ 2009.4.16
# ��������: ɾ��ָ��ISIS Router��ISIS Grid��
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# GridName	ISIS Grid�����Ʊ�ʶ��             ��ѡ                 ֧��
# �﷨����:                                                         
#      isis RemoveGrid -gridname grid1 
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::RemoveGrid {args} {
    ixDebugPuts "Enter proc IsisRouter::RemoveGrid...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set gridname ""
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-gridname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }  
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -gridname      {set gridName $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        
    set sg_networkRange $m_isisGridArray($gridName)
    ixNet remove $sg_networkRange
    ixNet commit
}
#====================================================================
# ��������: AddTopRouter  
# ������д: ��׿ 2009.6
# ��������: Ϊָ����ISIS Router����ISIS�������ˣ� Ixia����˵��, ������Ǵ���һ��1*1���߼�NetworkRange.
#           �ں���Ҫʹ��ConfigTopRouter��������, Ȼ��Ҫʹ��AddTopRouterLink�Լ�ConfigTopRouterLink�����NetworkRange
#           ��һ������ķ���·�ɽӿڽ�������. ����������������ý������ǽ����û���������,���浽һ��������,
#           ��ʹ��ddTopRouterLink�Լ�ConfigTopRouterLink��ʱ�������Щ������������ʵ��NetworkRange.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
#
# RouterName	     ISIS Router�����Ʊ�ʶ��                            
#                    Ҫ��ÿISIS�ھ�Ψһ�� 	��ѡ	      ��        ֧��            
# SystemID	    ISIS Router��SystemID	 ��ѡ	      1         ��֧��  
# RoutingId		                          ��ѡ	      1         ֧��
# PseudonodeNumber	α�ڵ�š�ֻ֧������16����������ʽ 		��֧��
# RoutingLevel	       ·�������		                        
# FlagTe	      ��������		                                ֧��
# FlagTag	        ��ǩ	                 ��ѡ	                ��֧��
# FlagMultiTopology	������		                                ��֧��
# FlagAdvertise  	ͨ�淽ʽ,enable/disable                         ֧��
# AddressFamily	         IPV4 IPV6 Both		                        ֧��
# FlagAttachedBit	��������������		                        ��֧��
# FlagOverLoadBit	����		                                ��֧��
# AreaId	        ����ID		                                 ��֧��
# 			
# AreaId1			
# AreaId2			
#
# �﷨����:                                                         
#      isis AddTopRouter -routername toprouter1 -routingid "00 00 00 00 00 00" 
#      
# ����ֵ��                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::AddTopRouter {args} {
    ixDebugPuts "Enter proc IsisRouter::AddTopRouter...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routerName     toprouter1
    set routingId      {00 00 00 88 88 00}
    set flagAdvertise  "enable"

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-routername}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routername     {set routerName $argx}
             -routingid      {set routingId $argx}
             -flagte         {set flagTe $argx}
             -addressfamily  {set addressFamily $argx}
             -flagadvertise {set flagAdvertise $argx}             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        set m_isisTopRouterParaArray($routerName,routerName) $routerName
        set m_isisTopRouterParaArray($routerName,routingId) $routingId
        set m_isisTopRouterParaArray($routerName,flagTe) $flagTe
        set m_isisTopRouterParaArray($routerName,addressFamily) $addressFamily
        set m_isisTopRouterParaArray($routerName,type) "router"
        set m_isisTopRouterParaArray($routerName,flagAdvertise) $flagAdvertise

}

#====================================================================
# ��������: ConfigTopRouter  
# ������д: ��׿ 2009.6
# ��������: Ϊָ����ISIS Router����ISIS�������ˣ� Ixia����˵��, ������Ǹ����Ѿ�������NetworkRange���޸����Ĳ���
#           Ȼ��Ҫʹ��AddTopRouterLink�Լ�ConfigTopRouterLink�����NetworkRange
#           ��һ������ķ���·�ɽӿڽ�������. ����������������ý������ǽ����û���������,���浽һ��������,
#           ��ʹ��ddTopRouterLink�Լ�ConfigTopRouterLink��ʱ�������Щ������������ʵ��NetworkRange.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
#
# RouterName	     ISIS Router�����Ʊ�ʶ��                            
#                    Ҫ��ÿISIS�ھ�Ψһ�� 	��ѡ	      ��        ֧��            
# SystemID	    ISIS Router��SystemID	 ��ѡ	      1         ��֧��  
# RoutingId		                          ��ѡ	      1         ֧��
# PseudonodeNumber	α�ڵ�š�ֻ֧������16����������ʽ 		��֧��
# RoutingLevel	       ·�������		                        
# FlagTe	      ��������		                                ֧��
# FlagTag	        ��ǩ	                 ��ѡ	                ��֧��
# FlagMultiTopology	������		                                ��֧��
# FlagAdvertise  	ͨ�淽ʽ,enable/disable                         ֧��
# AddressFamily	         IPV4 IPV6 Both		                        ֧��
# FlagAttachedBit	��������������		                        ��֧��
# FlagOverLoadBit	����		                                ��֧��
# AreaId	        ����ID		                                 ��֧��
# 			
# AreaId1			
# AreaId2			
#
# �﷨����:                                                         
#      isis ConfigTopRouter -routername toprouter1 -routingid "00 00 00 00 00 00" 
#      
# ����ֵ��                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::ConfigTopRouter {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigTopRouter...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routerName     toprouter1
    set routingId      {00 00 00 88 88 00}
    set flagAdvertise  "enable"

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-routername}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routername     {set routerName $argx}
             -routingid      {set routingId $argx}
             -flagte         {set flagTe $argx}
             -addressfamily  {set addressFamily $argx}
             -flagadvertise {set flagAdvertise $argx}             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        set m_isisTopRouterParaArray($routerName,routerName) $routerName
        set m_isisTopRouterParaArray($routerName,routingId) $routingId
        set m_isisTopRouterParaArray($routerName,flagTe) $flagTe
        set m_isisTopRouterParaArray($routerName,addressFamily) $addressFamily
        set m_isisTopRouterParaArray($routerName,flagAdvertise) $flagAdvertise
        set m_isisTopRouterParaArray($routerName,type) "router"
        

}





#ͨ��! 2009.7.23
#====================================================================
# ��������:AddTopRouterLink
# ������д: ��׿ 2009.6
# ��������:  Ϊָ����ISIS Router����ISIS�������ˣ�
# Ixia����: �����Ѿ�������TopRouter,(��NetworkRange�Ĳ���),�����߼���1*1��NetworkRange�ҵ�ָ���ķ���·��
#           �ӿ�֮��.��ʵ���������������������Ѿ����ڵ�һ��ISIS Router�ӿ��´���һ��NetworkRange,�����NetworkRange
#           �Ĳ���ֵ��ǰ�����õ�TopRouter�Ĳ���ֵ����.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# RouterName	 ����Ƿ���ӿ�Router�����Ʊ�ʶ           ��ѡ	      ��        ֧��
# Ipv4Address    ����Ƿ���ӿڵ�IP��ַ       ��ѡ	      ��        ֧��                 
# Ipv6Address	���1*1��First RouteIPv6��ַ      ��ѡ	      ��        ֧�� 
# ConnectedName	 �����TopRouter��TopNetwork������                                ��        ֧��		
# NeiIpv4Address	�����TopRouter��TopNetwork��IP		              ��        ֧��
# NeiIpv6Address	�ھ�ipv6��ַ		                        ��֧��
# FlagTe	�������� 		                                ��֧��
# FlagTag	��ǩ	��ѡ	                                        ��֧��
# FlagAdvertise	ͨ�淽ʽ		                                ֧��    
# NarrowMetric	խ����		                                        ��֧��
# WideMetric	�����	enable/diasble                                  ֧��
# MaxBandwith	������		                                ��֧��
# ReservableBandwith	Ԥ������		                        ��֧��
# AdminGroup	������		                                        ��֧��
# UnreservedBw	�����ƴ���		                                ��֧��
# LinkName	�ڽ�����		                                ֧��
#
# �﷨����:                                                         
#      isis AddTopRouterLink -routername toprouter1 -ipv4address 200.1.1.1 -neiipv4address 20.3.17.2 \
                             -flagadvertise enable
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::AddTopRouterLink {args} {
    ixDebugPuts "Enter proc IsisRouter::AddTopRouterLink...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  

    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routerName toprouter1
    set flagAdvetisted "enable"
    set gridRows 1
    set gridCols 1
    set ipv4Address 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    set wideMetric "disable"

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]


    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-routername}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routername      {set routerName $argx}
             -connectedname    {set connectedName $argx}
             -ipv4address      {set ipv4Address $argx}
             -neiipv4address      {set neiipv4Address $argx}
             -flagadvertise    {set flagAdvertise $argx}
             -widemetric        {set wideMetric $argx}
             -linkname          {set linkName $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }

    if {$m_isisTopRouterParaArray($connectedName,type) == "network"} {
        
        set networkName     $m_isisTopRouterParaArray($connectedName,networkName) 
        set addressFamily   $m_isisTopRouterParaArray($connectedName,addressFamily) 
        set firstAddress    $m_isisTopRouterParaArray($connectedName,firstAddress)  
        set numAddress      $m_isisTopRouterParaArray($connectedName,numAddress) 
        set startIpMask     $m_isisTopRouterParaArray($connectedName,prefixLen)
        
        set RID $m_isisRTNameToInterFaceID($routerName,RID)        
        set sg_networkRange [ixNet add $RID networkRange]
        set m_isisNetworkRange $sg_networkRange
        set m_isisGridArray($connectedName) $sg_networkRange
         if {$flagAdvertise == "enable"} {
            ixNet setAttribute $sg_networkRange -enabled True
         } else {
            ixNet setAttribute $sg_networkRange -enabled False
         }
         
         ixNet setAttribute $sg_networkRange -entryCol 1 
         ixNet setAttribute $sg_networkRange -entryRow 1
         ixNet setAttribute $sg_networkRange -gridNodeRoutes  {  }
         ixNet setAttribute $sg_networkRange -gridOutsideLinks  {  }
         ixNet setAttribute $sg_networkRange -interfaceIps  [list [list $addressFamily $firstAddress $startIpMask] ]
         #ixNet setAttribute $sg_networkRange -interfaceIps  { {ipv4 0.0.0.0 24} }
         ixNet setAttribute $sg_networkRange -interfaceMetric 1
         ixNet setAttribute $sg_networkRange -linkType broadcast ;#pointToPoint
         ixNet setAttribute $sg_networkRange -noOfCols $numAddress
         ixNet setAttribute $sg_networkRange -noOfRows 1
         ixNet setAttribute $sg_networkRange -routerId {00 00 00 00 00 01}
         ixNet setAttribute $sg_networkRange -routerIdIncrement {00 00 00 00 00 01 }
         ixNet setAttribute $sg_networkRange -tePaths  {  }
         if  {$wideMetric == "enable"} {
            ixNet setAttribute $sg_networkRange -useWideMetric True
         } else {
         ixNet setAttribute $sg_networkRange -useWideMetric False   
         }
         
         

    
        ixNet commit
    
    } elseif {$m_isisTopRouterParaArray($connectedName,type) == "router" } {
        
        
        set connectedName $m_isisTopRouterParaArray($connectedName,routerName)
        set routingId $m_isisTopRouterParaArray($connectedName,routingId)
        set flagTe $m_isisTopRouterParaArray($connectedName,flagTe)
        set addressFamily $m_isisTopRouterParaArray($connectedName,addressFamily)
        set flagAdvertise $m_isisTopRouterParaArray($connectedName,flagAdvertise) 
        set RID $m_isisRTNameToInterFaceID($routerName,RID)    
        set sg_networkRange [ixNet add $RID networkRange]
        set m_isisNetworkRange $sg_networkRange
        set m_isisGridArray($connectedName) $sg_networkRange
         if {$flagAdvertise == "enable"} {
            ixNet setAttribute $sg_networkRange -enabled True
         } else {
            ixNet setAttribute $sg_networkRange -enabled False
         }
         
         ixNet setAttribute $sg_networkRange -entryCol 1 
         ixNet setAttribute $sg_networkRange -entryRow 1
         ixNet setAttribute $sg_networkRange -gridNodeRoutes  {  }
         ixNet setAttribute $sg_networkRange -gridOutsideLinks  {  }
         ixNet setAttribute $sg_networkRange -interfaceIps  [list [list $addressFamily $neiipv4Address 24] ]
         ixNet setAttribute $sg_networkRange -interfaceMetric 1
         ixNet setAttribute $sg_networkRange -linkType broadcast ;#pointToPoint
         ixNet setAttribute $sg_networkRange -noOfCols 1
         ixNet setAttribute $sg_networkRange -noOfRows 1
         ixNet setAttribute $sg_networkRange -routerId $routingId
         ixNet setAttribute $sg_networkRange -routerIdIncrement {00 00 00 00 00 01 }
         ixNet setAttribute $sg_networkRange -tePaths  {  }
         if  {$wideMetric == "enable"} {
            ixNet setAttribute $sg_networkRange -useWideMetric True
         } else {
         ixNet setAttribute $sg_networkRange -useWideMetric False   
         }
         
         
        if {$flagTe == "enable"} {
            ixNet setMultiAttrs $sg_networkRange/entryTe \
             -enableEntryTe True \
             -eteAdmGroup {00 00 00 00} \
             -eteLinkMetric 0 \
             -eteMaxBandWidth 0 \
             -eteMaxReserveBandWidth 0 \
             -eteRouterId 0.0.0.1 \
             -eteRouterIdIncrement 0.0.0.1 \
             -eteUnreservedBandWidth {0 0 0 0 0 0 0 0}
            ixNet setMultiAttrs $sg_networkRange/rangeTe \
             -enableRangeTe True \
             -teAdmGroup {00 00 00 00} \
             -teLinkMetric 0 \
             -teMaxBandWidth 0 \
             -teMaxReserveBandWidth 0 \
             -teRouterId 0.0.0.1 \
             -teRouterIdIncrement 0.0.0.1 \
             -teUnreservedBandWidth {0 0 0 0 0 0 0 0}          
        }

        ixNet commit  
        
    } else {
        puts "Wrong type of Network or Router, please check."
    }
    
    set sg_networkRange [lindex [ixNet remapIds $sg_networkRange] 0]
    puts "Fininshed!"
}




#====================================================================
# ��������:ConfigTopRouterLink
# ������д: ��׿ 2009.6
# ��������:  Ϊָ����ISIS Router����ISIS�������ˣ�
# Ixia����: �����Ѿ�������TopRouter,(��NetworkRange�Ĳ���),�����߼���1*1��NetworkRange�ҵ�ָ���ķ���·��
#           �ӿ�֮��.��ʵ���������������������Ѿ����ڵ�һ��ISIS Router�ӿ��´���һ��NetworkRange,�����NetworkRange
#           �Ĳ���ֵ��ǰ�����õ�TopRouter�Ĳ���ֵ����.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��         
# RouterName	 ����Ƿ���ӿ�Router�����Ʊ�ʶ           ��ѡ	      ��        ֧��
# Ipv4Address    ����Ƿ���ӿڵ�IP��ַ       ��ѡ	      ��        ֧��                 
# Ipv6Address	���1*1��First RouteIPv6��ַ      ��ѡ	      ��        ֧�� 
# ConnectedName	 �����TopRouter��TopNetwork������                                ��        ֧��		
# NeiIpv4Address	�����TopRouter��TopNetwork��IP		              ��        ֧��
# NeiIpv6Address	�ھ�ipv6��ַ		                        ��֧��
# FlagTe	�������� 		                                ��֧��
# FlagTag	��ǩ	��ѡ	                                        ��֧��
# FlagAdvertise	ͨ�淽ʽ		                                ֧��    
# NarrowMetric	խ����		                                        ��֧��
# WideMetric	�����	enable/diasble                                  ֧��
# MaxBandwith	������		                                ��֧��
# ReservableBandwith	Ԥ������		                        ��֧��
# AdminGroup	������		                                        ��֧��
# UnreservedBw	�����ƴ���		                                ��֧��
# LinkName	�ڽ�����		                                ֧��
#
# �﷨����:                                                         
#      isis ConfigTopRouterLink -routername toprouter1 -ipv4address 200.1.1.1 -neiipv4address 20.3.17.2 \
                             -flagadvertise enable
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::ConfigTopRouterLink {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigTopRouterLink...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  

    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routerName toprouter1
    set flagAdvetise "enable"
    set gridRows 1
    set gridCols 1
    set ipv4Address 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    set wideMetric "disable"
    set neiipv4Address 201.1.1.1

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]


    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-routername}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routername      {set routerName $argx}
             -connectedname    {set connectedName $argx}
             -ipv4address      {set ipv4Address $argx}
             -neiipv4address      {set neiipv4Address $argx}
             -flagadvertise    {set flagAdvertise $argx}
             -widemetric        {set wideMetric $argx}
             -linkname          {set linkName $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
   if {$m_isisTopRouterParaArray($connectedName,type) == "network"} {
        
        set networkName     $m_isisTopRouterParaArray($connectedName,networkName) 
        set addressFamily   $m_isisTopRouterParaArray($connectedName,addressFamily) 
        set firstAddress    $m_isisTopRouterParaArray($connectedName,firstAddress)  
        set numAddress      $m_isisTopRouterParaArray($connectedName,numAddress) 
        set startIpMask     $m_isisTopRouterParaArray($connectedName,prefixLen)
        


        set sg_networkRange $m_isisGridArray($connectedName) 
         if {$flagAdvertise == "enable"} {
            ixNet setAttribute $sg_networkRange -enabled True
         } else {
            ixNet setAttribute $sg_networkRange -enabled False
         }
         
         ixNet setAttribute $sg_networkRange -entryCol 1 
         ixNet setAttribute $sg_networkRange -entryRow 1
         ixNet setAttribute $sg_networkRange -gridNodeRoutes  {  }
         ixNet setAttribute $sg_networkRange -gridOutsideLinks  {  }
         ixNet setAttribute $sg_networkRange -interfaceIps  [list [list $addressFamily $firstAddress $startIpMask] ]
         #ixNet setAttribute $sg_networkRange -interfaceIps  { {ipv4 0.0.0.0 24} }
         ixNet setAttribute $sg_networkRange -interfaceMetric 1
         ixNet setAttribute $sg_networkRange -linkType broadcast ;#pointToPoint
         ixNet setAttribute $sg_networkRange -noOfCols $numAddress
         ixNet setAttribute $sg_networkRange -noOfRows 1
         ixNet setAttribute $sg_networkRange -routerId {00 00 00 00 00 01}
         ixNet setAttribute $sg_networkRange -routerIdIncrement {00 00 00 00 00 01 }
         ixNet setAttribute $sg_networkRange -tePaths  {  }
         if  {$wideMetric == "enable"} {
            ixNet setAttribute $sg_networkRange -useWideMetric True
         } else {
         ixNet setAttribute $sg_networkRange -useWideMetric False   
         }
         
         

    
        ixNet commit
    
    } elseif {$m_isisTopRouterParaArray($connectedName,type) == "router" } {
        
        
        set connectedName $m_isisTopRouterParaArray($connectedName,routerName)
        set routingId $m_isisTopRouterParaArray($connectedName,routingId)
        set flagTe $m_isisTopRouterParaArray($connectedName,flagTe)
        set addressFamily $m_isisTopRouterParaArray($connectedName,addressFamily)
        set flagAdvertise $m_isisTopRouterParaArray($connectedName,flagAdvertise) 
        #set RID $m_isisIPToInterFaceID($neiipv4Address,RID)
        set sg_networkRange $m_isisGridArray($connectedName) 
         if {$flagAdvertise == "enable"} {
            ixNet setAttribute $sg_networkRange -enabled True
         } else {
            ixNet setAttribute $sg_networkRange -enabled False
         }
         
         ixNet setAttribute $sg_networkRange -entryCol 1 
         ixNet setAttribute $sg_networkRange -entryRow 1
         ixNet setAttribute $sg_networkRange -gridNodeRoutes  {  }
         ixNet setAttribute $sg_networkRange -gridOutsideLinks  {  }
         ixNet setAttribute $sg_networkRange -interfaceIps  [list [list $addressFamily $neiipv4Address 24] ]
         ixNet setAttribute $sg_networkRange -interfaceMetric 1
         ixNet setAttribute $sg_networkRange -linkType broadcast ;#pointToPoint
         ixNet setAttribute $sg_networkRange -noOfCols 1
         ixNet setAttribute $sg_networkRange -noOfRows 1
         ixNet setAttribute $sg_networkRange -routerId $routingId
         ixNet setAttribute $sg_networkRange -routerIdIncrement {00 00 00 00 00 01 }
         ixNet setAttribute $sg_networkRange -tePaths  {  }
         if  {$wideMetric == "enable"} {
            ixNet setAttribute $sg_networkRange -useWideMetric True
         } else {
         ixNet setAttribute $sg_networkRange -useWideMetric False   
         }
         
         
        if {$flagTe == "enable"} {
            ixNet setMultiAttrs $sg_networkRange/entryTe \
             -enableEntryTe True \
             -eteAdmGroup {00 00 00 00} \
             -eteLinkMetric 0 \
             -eteMaxBandWidth 0 \
             -eteMaxReserveBandWidth 0 \
             -eteRouterId 0.0.0.1 \
             -eteRouterIdIncrement 0.0.0.1 \
             -eteUnreservedBandWidth {0 0 0 0 0 0 0 0}
            ixNet setMultiAttrs $sg_networkRange/rangeTe \
             -enableRangeTe True \
             -teAdmGroup {00 00 00 00} \
             -teLinkMetric 0 \
             -teMaxBandWidth 0 \
             -teMaxReserveBandWidth 0 \
             -teRouterId 0.0.0.1 \
             -teRouterIdIncrement 0.0.0.1 \
             -teUnreservedBandWidth {0 0 0 0 0 0 0 0}          
        }

        ixNet commit  
        
    } else {
        puts "Wrong type of Network or Router, please check."
    }
    
    set sg_networkRange [lindex [ixNet remapIds $sg_networkRange] 0]
    puts "Fininshed!"
}

#ͨ��! 2009.7.23
#====================================================================
# ��������: AddTopNetwork  
# ������д: ��׿ 2009.6
# ��������: Ϊָ����ISIS Router����ISIS�������ˣ� Ixia����˵��, ������Ǵ���һ��1*N���߼�NetworkRange.
#           �ں���Ҫʹ��ConfigTopNetwork��������, Ȼ��Ҫʹ��AddTopRouterLink�Լ�ConfigTopRouterLink�����NetworkRange
#           ��һ������ķ���·�ɽӿڽ�������. ����������������ý������ǽ����û���������,���浽һ��������,
#           ��ʹ��ddTopRouterLink�Լ�ConfigTopRouterLink��ʱ�������Щ������������ʵ��NetworkRange.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
#
# NetworkName	     ISIS Network�����Ʊ�ʶ��    ��ѡ	      ��        ֧��            
# AddressFamily	         IPV4 IPV6 Both		                        ֧��
# FirstAddress		                                                ֧��
# NumAddress                                             		֧��
# Modifier	       ÿ������仯�Ĳ���                     1	        ֧��	                        
# Prefixlen	      	                                      24        ֧��
# 					
#
# �﷨����:                                                         
#      IsisRouter1 AddTopNetwork -NetworkName Network1 \
#	    -FirstAddress 101.0.0.1 -NumAddress 20 \
#           -Prefixlen 32 \
#           -Modifier 1   \
#      
# ����ֵ��                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::AddTopNetwork {args} {
    ixDebugPuts "Enter proc IsisRouter::AddTopNetwork...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set networkName     topnetwork1
    set addressFamily   ipv4

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-networkname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -networkname     {set networkName $argx}
             -firstaddress         {set firstAddress $argx}
             -addressfamily  {set addressFamily $argx}
             -numaddress  {set numAddress $argx}
             -modifier     {set modifier $argx}
             -prefixlen     {set prefixLen $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        set m_isisTopRouterParaArray($networkName,networkName) $networkName
        set m_isisTopRouterParaArray($networkName,addressFamily) $addressFamily
        set m_isisTopRouterParaArray($networkName,firstAddress)  $firstAddress
        set m_isisTopRouterParaArray($networkName,numAddress) $numAddress
        set m_isisTopRouterParaArray($networkName,modifier) $modifier
        set m_isisTopRouterParaArray($networkName,prefixLen) $prefixLen
        set m_isisTopRouterParaArray($networkName,type) "network"
}




#ͨ��! 2009.7.23
#====================================================================
# ��������: ConfigTopNetwork  
# ������д: ��׿ 2009.6
# ��������: Ϊָ����ISIS Router����ISIS�������ˣ� Ixia����˵��, �������Ϊ�Ѿ�������һ��1*N���߼�NetworkRange���޸Ĳ���.
#           Ȼ��Ҫʹ��AddTopRouterLink�Լ�ConfigTopRouterLink�����NetworkRange
#           ��һ������ķ���·�ɽӿڽ�������. ����������������ý������ǽ����û���������,���浽һ��������,
#           ��ʹ��ddTopRouterLink�Լ�ConfigTopRouterLink��ʱ�������Щ������������ʵ��NetworkRange.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
#
# NetworkName	     ISIS Network�����Ʊ�ʶ��    ��ѡ	      ��        ֧��            
# AddressFamily	         IPV4 IPV6 Both		                        ֧��
# FirstAddress		                                                ֧��
# NumAddress                                             		֧��
# Modifier	       ÿ������仯�Ĳ���                     1	        ֧��	                        
# Prefixlen	      	                                      24        ֧��
# 					
#
# �﷨����:                                                         
#      IsisRouter1 ConfigTopNetwork -NetworkName Network1 \
#	    -FirstAddress 102.0.0.1 -NumAddress 20 \
#           -Prefixlen 24 \
#           -Modifier 1   \
#      
# ����ֵ��                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::ConfigTopNetwork {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigTopNetwork...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set networkName     topnetwork1
    set addressFamily   ipv4

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-networkname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -networkname     {set networkName $argx}
             -firstaddress         {set firstAddress $argx}
             -addressfamily  {set addressFamily $argx}
             -numaddress  {set numAddress $argx}
             -modifier     {set modifier $argx}
             -prefixlen     {set prefixLen $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        set m_isisTopRouterParaArray($networkName,networkName) $networkName
        set m_isisTopRouterParaArray($networkName,addressFamily) $addressFamily
        set m_isisTopRouterParaArray($networkName,firstAddress)  $firstAddress
        set m_isisTopRouterParaArray($networkName,numAddress) $numAddress
        set m_isisTopRouterParaArray($networkName,modifier) $modifier
        set m_isisTopRouterParaArray($networkName,prefixLen) $prefixLen
        set m_isisTopRouterParaArray($networkName,type) "network"
}

#Pass!
#====================================================================
# ��������:RemoveTopNetwork  
# ������д: ��׿ 2009.6
# ��������: ɾ��ָ����ISIS Grid��
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# GridName	ISIS Grid�����Ʊ�ʶ��             ��ѡ                 ֧��
# �﷨����:                                                         
#      isis RemoveTopNetwork -networkname topnetwork1 
# ����ֵ��                                                          
#      none              
#====================================================================
itcl::body IsisRouter::RemoveTopNetwork {args} {
    ixDebugPuts "Enter proc IsisRouter::RemoveTopNetwork...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set networkName ""
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-networkname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }  
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -networkname      {set networkName $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        
    set sg_networkRange $m_isisGridArray($networkName)
    ixNet remove $sg_networkRange
    ixNet commit
}

#ͨ��! 2009.7.23
#====================================================================
# ��������:RemoveTopRouter 
# ������д: ��׿ 2009.6
# ��������: ɾ��ָ����ISIS TopRouter��Ixiaʵ��,����ɾ���Ѿ����ڵ�NetworkRange
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# Routername  	ISIS TopRouter�����Ʊ�ʶ��             ��ѡ                 ֧��
# �﷨����:                                                         
#      isis RemoveTopRouter -routername toprouter1 
# ����ֵ��                                                          
#      none              
#====================================================================
itcl::body IsisRouter::RemoveTopRouter {args} {
    ixDebugPuts "Enter proc IsisRouter::RemoveTopRouter...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routerName ""
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-routername}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }  
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routername      {set routerName $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
        
    set sg_networkRange $m_isisGridArray($routerName)
    ixNet remove $sg_networkRange
    ixNet commit
}




#ͨ��
#====================================================================
# ��������: CreateRouteBlock
# ������д: ��׿ 2009.4.2
# ��������: Ϊָ����ISIS Router ����Isis·�ɿ�Ĳ�������Ϊָ����·��������һ��RouteRange.
# ���ݺ�ZTE��ȷ��.��Create��Config��ʱ��,��Ҫ����ΪDisable��״̬,ֻ�е�Advertising��ʱ��������ΪEnable��״̬.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockName	    ISIS·�ɿ�����Ʊ�ʶ         ��ѡ	     ��        ֧��
# RoutePoolType	    IPV4 IPV6 	                 ��ѡ	     IPV4       ֧��        
# FirstAddress	    ��ʼ��ַ	                 ��ѡ	     10.10.10.1 ֧��
#  PrefixLen	    ���볤��		         ��ѡ        24         ֧��
# NumAddress	    ������ַ���еĵ�ַ��Ŀ	��ѡ	     10         ֧��
# Modifier	    ����ֵ, ������              ��ѡ	     1          ��֧��
# �﷨����:                                                         
#      isis AddGrid 
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::CreateRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::CreateRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockName     routeRange1
    set routePoolType ipv4
    set firstAddress  10.10.10.1 
    set prefixLen 24
    set numAddress 10
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname -routepooltype -firstaddress -prefixlen -numaddress}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }
    
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {set blockName $argx}
             -routepooltype      {set routePoolType $argx}
             -firstaddress      {set firstAddress $argx}
             -prefixlen      {set prefixLen $argx}
             -numaddress        {set numAddress $argx}
             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    set sg_routeRange [ixNet add $m_isisRouter routeRange]
    set m_isisBlockArray($blockName)  $sg_routeRange
    #puts "m_isisBlockArray($blockName)= $m_isisBlockArray($blockName)"
        ixNet setAttribute $sg_routeRange -enabled False 
        ixNet setAttribute $sg_routeRange -firstRoute $firstAddress 
        ixNet setAttribute $sg_routeRange -isRedistributed False 
        ixNet setAttribute $sg_routeRange -maskWidth $prefixLen 
        ixNet setAttribute $sg_routeRange -metric 0
        ixNet setAttribute $sg_routeRange -numberOfRoutes $numAddress
        ixNet setAttribute $sg_routeRange -routeOrigin False 
        ixNet setAttribute $sg_routeRange -type $routePoolType
        ixNet commit
        set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]


}

#====================================================================
# ��������: CheckEssentialArgs
# ������д: ��׿ 2009.4.2
# ��������: ��麯���Ƿ��б�ѡ����û������.
# �﷨����:                                                         
#      CheckEssentialArgs $tmpList $essAgs ��һ�������������б�,�ڶ��������Ǳ�ѡ�����б�
# ����ֵ��                                                          
#      �ɹ�����0 ʧ�ܷ���1                  
#====================================================================
itcl::body IsisRouter::CheckEssentialArgs {tmpList essArgs} {
    set argsFlag 0
    for {set i 0} {$i < [llength $essArgs]} {incr i} {
        set tempVal [lindex $essArgs $i]
        if {[lsearch $tmpList $tempVal] < 0 } {
            puts "$tempVal didn't configured,please check!"
            set argsFlag 1
        }
    }    
    return $argsFlag
}

#ͨ��
#====================================================================
# ��������: ConfigRouteBlock
# ������д: ��׿ 2009.4.2
# ��������: Ϊָ����ISIS Router ����Isis·�ɿ�Ĳ�������Ϊָ����·��������һ��RouteRange.
# ���ݺ�ZTE��ȷ��.��Create��Config��ʱ��,��Ҫ����ΪDisable��״̬,ֻ�е�Advertising��ʱ��������ΪEnable��״̬.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockName	    �Ѿ����ڵ�ISIS·�ɿ�����Ʊ�ʶ ��ѡ	     ��        ֧��     
# FirstAddress	    ��ʼ��ַ	                 ��ѡ	     10.10.10.1 ֧��
#  PrefixLen	    ���볤��		         ��ѡ        24         ֧��
# NumAddress	    ������ַ���еĵ�ַ��Ŀ	��ѡ	     10         ֧��
# Modifier	    ����ֵ	                ��ѡ	     1          ��֧��
# �﷨����:                                                         
#      isis1 ConfigRouteBlock -blockname routeRange -FirstAddress 101.1.1.0 \
         -PrefixLen 24 -NumAddress 3 
# ����ֵ��                                                          
#      �ɹ���ֹ isis router �򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body IsisRouter::ConfigRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::ConfigRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockName     routeRange1
    set routePoolType ipv4
    set firstAddress  10.10.10.1 
    set prefixLen 24
    set numAddress 10
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {set blockName $argx}
             -firstaddress      {set firstAddress $argx}
             -prefixlen      {set prefixLen $argx}
             -numaddress        {set numAddress $argx}
             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    set sg_routeRange $m_isisBlockArray($blockName)
    ixNet setAttribute $sg_routeRange -enabled False 
    ixNet setAttribute $sg_routeRange -firstRoute $firstAddress 
    ixNet setAttribute $sg_routeRange -isRedistributed False 
    ixNet setAttribute $sg_routeRange -maskWidth $prefixLen 
    ixNet setAttribute $sg_routeRange -metric 0
    ixNet setAttribute $sg_routeRange -numberOfRoutes $numAddress
    ixNet setAttribute $sg_routeRange -routeOrigin False 
    ixNet commit
    set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]


}




#ͨ��
#====================================================================
# ��������: GetRouteBlock
# ������д: ��׿ 2009.4.2
# ��������:  �г���Router�İ����еĵ�ַ��, ����ӡ����RouteBlock������
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockNanme            ISIS·�ɿ������           ��ѡ	     ��        ֧��     
# �﷨����:                                                         
#      IsisRouter  GetRouteBlock -blockname routerange                                                
#                       
#====================================================================
itcl::body IsisRouter::GetRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::GetRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockNanmeList  routerange

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set value [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {
                set blockName $value
                set sg_routeRange $m_isisBlockArray($blockName) }
             -routepooltype {
                set SConfig [ixNet getAttribute $sg_routeRange -type]
                upvar $value arg
                set arg $SConfig
                         }
             -firstaddress  {
                set SConfig [ixNet getAttribute $sg_routeRange -firstRoute]
                upvar $value arg
                set arg $SConfig
                }
             -numaddress {
                set SConfig [ixNet getAttribute $sg_routeRange -numberOfRoutes]
                upvar $value arg
                set arg $SConfig                
             }
             -prefixlen {
                set SConfig [ixNet getAttribute $sg_routeRange -maskWidth]
                upvar $value arg
                set arg $SConfig                                  
             }
             default     {
                 puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
}

#ͨ��
#====================================================================
# ��������: DeleteRouteBlock
# ������д: ��׿ 2009.4.2
# ��������:  ɾ��ָ��ISIS Router��·�ɿ�, ��ɾ��ָ����·�����µ�ָ����RouteRange.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockName	    �Ѿ����ڵ�ISIS·�ɿ�����Ʊ�ʶ ��ѡ	     ��        ֧��     
# �﷨����:                                                         
#      sisRouter  DeleteRouteBlock �CBlockName routerange1                                                           
#                       
#====================================================================
itcl::body IsisRouter::DeleteRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::DeleteRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockName     routeRange1
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }
    
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {set blockName $argx}             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    set sg_routeRange $m_isisBlockArray($blockName)
    ixNet remove $sg_routeRange 
    ixNet commit
    #set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]

}



#ͨ��
#====================================================================
# ��������: ListRouteBlock
# ������д: ��׿ 2009.4.2
# ��������:  �г���Router�İ����еĵ�ַ��, ����ӡ����ISISrouter�µ����е�RouteRanges.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockNanmeList ISIS·�ɿ�����Ʊ�ʶ����        ��ѡ	     ��        ֧��     
# �﷨����:                                                         
#      IsisRouter  CreateRouteBlock -BlockNanmeList [list routeRange1 routeRange2]                                                    
#                       
#====================================================================
itcl::body IsisRouter::ListRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::ListRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockNanmeList     ""
    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #while { $tmpllength > 0  } {
    #    set cmdx [lindex $args $idxxx]
    #    set argx [lindex $args [expr $idxxx + 1]]
    #
    #    case $cmdx      {
    #         -blocknamelist      {set blockNameList $argx}             
    #         default     {
    #                      puts "Error : cmd option $cmdx does not exist"
    #                     }
    #    }
    #    incr idxxx  +2
    #    incr tmpllength -2
    #    }

    #for {set i 0} {$i< [llength $blockNameList]} {incr i} {
    #    set blockName [lindex $blockNameList $i]
    #    puts "\n\n========================================="
    #    puts "BlockName: $blockName"
    #    set sg_routeRange $m_isisBlockArray($blockName)        
    #    puts "FirstRoute: [ixNet getAttribute $sg_routeRange -firstRoute]"
    #    puts "PrefixLen: [ixNet getAttribute $sg_routeRange -maskWidth ]"
    #    puts "NumberOfRoutes: [ixNet getAttribute $sg_routeRange -numberOfRoutes]"
    #    puts "RoutePoolType: [ixNet getAttribute $sg_routeRange -type]"
    #    
    #}
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blocknamelist}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set value [lindex $args [expr $idxxx + 1]]
        case $cmdx      {
             -blocknamelist {
                set tList  [array get m_isisBlockArray]
                set fList ""
                for {set i 0} {$i<= [llength $tList]} {incr i 2} {
                set temp1 [lindex $tList $i]
                if {$temp1 != ""} {
                    lappend fList [lindex $tList $i]
                }                
                }
                set SConfig $fList
                upvar $value arg
                set arg $SConfig
                }
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
}

#ͨ��
#====================================================================
# ��������: AdvertiseRouteBlock
# ������д: ��׿ 2009.4.8
# ��������: Ϊָ����ISIS Router ��RouteRange��ʼAdvertising.ǰ���������û�
#           �Ѿ�ʹ��startRoute��ʼ�����·�ɷ���.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockName	    �Ѿ����ڵ�ISIS·�ɿ�����Ʊ�ʶ ��ѡ	     ��        ֧��     
#
# �﷨����:                                                         
#      IsisRouter AdvertiseRouteBlock  �CBlockName RouteRange1
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::AdvertiseRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::AdvertiseRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockName     routeRange1    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }    
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {set blockName $argx}

             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    set sg_routeRange $m_isisBlockArray($blockName)
    ixNet setAttribute $sg_routeRange -enabled True 
    ixNet commit
    set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]
}

#ͨ��
#====================================================================
# ��������: WithdrawRouteBlock
# ������д: ��׿ 2009.4.8
# ��������: Ϊָ����ISIS Router ��RouteRange �����Ѿ��㲥��·��.ǰ���������û�
#           �Ѿ�ʹ��startRoute��ʼ�����·�ɷ���.�����Ѿ��㲥��·��.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# BlockName	    �Ѿ����ڵ�ISIS·�ɿ�����Ʊ�ʶ ��ѡ	     ��        ֧��     
#
# �﷨����:                                                         
#      IsisRouter WithdrawRouteBlock  �CBlockName RouteRange1
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::WithdrawRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::WithdrawRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set blockName     routeRange1    
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname}
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }        
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {set blockName $argx}

             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    set sg_routeRange $m_isisBlockArray($blockName)
    ixNet setAttribute $sg_routeRange -enabled False 
    ixNet commit
    set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]
}

#====================================================================
# ��������: ConfigFlap 
# ������д: ��׿ 2009.5.5
# ��������: �ú���ʵ������TopRouter��Grid,��ΪISIS��֧��TopRouter,�����������GRID
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# AWDTimer     Advertise to Withdraw Delay  ms    ��ѡ	     ��        ֧��     
# WADTimer     Withdraw toAdvertise Delay   ms    ��ѡ	     ��        ֧��   
# �﷨����:                                                         
#     isisRouter ConfigFlapRouteBlock  �CAWDTimer $time1 �CWADTimerr $time2
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::ConfigFlap {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigFlap...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set awdTimer  60000 ;#60 seconds
    set wadTimer  60000
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -wadtimer      {set wadTimer $argx}
             -awdtimer      {set awdTimer $argx}             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }    
    set m_flapRouterTimerList [list $awdTimer $wadTimer]
}

#====================================================================
# ��������: StartFlapRouters  
# ������д: ��׿ 2009.4.28
# ��������: ����ZTE����,�ú���ʵ������TopRouter��Grid����,
#           ��ΪIxia��ISIS��֧��TopRouter,��������ͽ�����һ��Router�µ����д��ڵ�GRID
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��
# BlockName     ISIS·�ɿ����Ʊ�ʶ                 ��ѡ	     ��        ֧��
# Flapinterval  ÿ���𵴼��ʱ��      ms             ��ѡ      ��        ֧��
# Flapnumber    �𵴵Ĵ���                         ��ѡ      ��        ֧��
# �﷨����:                                                         
#    Isisrouter1  StartFlapRoutes  �Cflapinterval 10000 �Cflapnumber 60000
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::StartFlapRouters {args} {
    ixDebugPuts "Enter proc IsisRouter::StartFlapRouters...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set Flapinterval  10000
    set Flapnumber  1
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -flapinterval   {set flapInterval $argx}
             -flapnumber     {set flapNumber $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    set awdTimer [lindex $m_flapRouterTimerList 0]
    set wadTimer [lindex $m_flapRouterTimerList 1]
    #get all the network range under this router.
    set gridList [ixNet getList $m_ixRouterId networkRange]
    #puts "Grid List is $gridList"
    
    for {set i 0} {$i < $flapNumber} {incr i} {
        puts "\n\n Starting Flapping : Iteration No.[expr $i+1] "
        #Advertising all the networkrange Routes        
        foreach gridId $gridList {
            puts "$gridId Enabled!"
            ixNet setAttribute $gridId  -enabled True
            ixNet commit    
        }
        puts "Routes Advertised, wait for $awdTimer ms..."
        after  $awdTimer
        #Withdraw all the networkrange Routes        
        foreach gridId $gridList {
            puts "$gridId Disabled!"
            ixNet setAttribute $gridId  -enabled False
            ixNet commit    
        }
        puts "Routes Withdraw, wait for $wadTimer ms..."
        after $wadTimer        
        puts "Wait for $flapInterval seconds for Flap Interval..."
    }
}

#====================================================================
# ��������: StopFlapRoutes 
# ������д: ��׿ 2009.5.5
# ��������:  ֹͣ��ISIS����·����
# �������: No
# �﷨����:                                                         
#    Isisrouter1  StopFlapRouters
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::StopFlapRouters {} {
    ixDebugPuts "Enter proc IsisRouter::StopFlapRoutes...\n"
    puts "Stop Flapping Routes"
    set gridList [ixNet getList $m_ixRouterId networkRange]
    foreach gridId $gridList {
            ixNet setAttribute $gridId  -enabled False
            ixNet commit    
        }

}

#Pass
#====================================================================
# ��������: ConfigFlapRouteBlock 
# ������д: ��׿ 2009.4.28
# ��������: ���ø�Э���ַ�ص���Ƶ��
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# AWDTimer     Advertise to Withdraw Delay  ms    ��ѡ	     ��        ֧��     
# WADTimer     Withdraw toAdvertise Delay   ms    ��ѡ	     ��        ֧��   
# �﷨����:                                                         
#     isisRouter ConfigFlapRouteBlock  �CAWDTimer $time1 �CWADTimerr $time2
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::ConfigFlapRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigFlapRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set awdTimer  60000
    set wadTimer  60000
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -wadtimer      {set wadTimer $argx}
             -awdtimer      {set awdTimer $argx}             
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }    
    set m_flapRouteBlockTimerList [list $awdTimer $wadTimer]
}

#Pass
#====================================================================
# ��������: StartFlapRouteBlock  
# ������д: ��׿ 2009.4.28
# ��������: ����Flap��־�ĵ�ַ��
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��
# BlockName     ISIS·�ɿ����Ʊ�ʶ                 ��ѡ	     ��        ֧��
# Flapinterval  ÿ���𵴼��ʱ��                   ��ѡ      ��        ֧��
# Flapnumber    �𵴵Ĵ���                         ��ѡ      ��        ֧��
# �﷨����:                                                         
#    Isisrouter1  StartFlapRouteBlock �CBlockName Blk1 �Cflapinterval $ʱ�� �Cflapnumber $number
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::StartFlapRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::StartFlapRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set Flapinterval  30
    set Flapnumber  1
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]

    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname -flapinterval -flapnumber }
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }        
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routername      {set routerName $argx}
             -blockname      {set blockName $argx}
             -flapinterval   {set flapInterval $argx}
             -flapnumber     {set flapNumber $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    set awdTimer [lindex $m_flapRouteBlockTimerList 0]
    set wadTimer [lindex $m_flapRouteBlockTimerList 1]
    for {set i 0} {$i < $flapNumber} {incr i} {
        puts "\n\n Starting Flapping RouteBlock $blockName : Iteration No.[expr $i+1] "
        #Advertising Routes        
        set sg_routeRange $m_isisBlockArray($blockName)
        ixNet setAttribute $sg_routeRange -enabled True 
        ixNet commit
        puts "Routes Advertised, wait for $awdTimer ms..."
        after  $awdTimer  
        #WithDraw Routes
        set sg_routeRange $m_isisBlockArray($blockName)
        ixNet setAttribute $sg_routeRange -enabled False
        ixNet commit
        puts "Routes Withdraw, wait for $wadTimer ms..."
        after  $wadTimer
        puts "Wait for $flapInterval seconds for Flap Interval..."
    }
}


#Pass
#====================================================================
# ��������: StopFlapRouteBlock  
# ������д: ��׿ 2009.4.30
# ��������: ����Flap��־�ĵ�ַ��
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��
# BlockName     ISIS·�ɿ����Ʊ�ʶ                 ��ѡ	     ��        ֧��
# �﷨����:                                                         
#    Isisrouter1  StopFlapRouteBlock �CBlockName Blk1 
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::StopFlapRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::StopFlapRouteBlock...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]

    #������һ���ж��Ƿ����еı�ѡ��������args��,���û��,�򱨴��˳�.
    set essAgs {-blockname }
    set argsFlag [CheckEssentialArgs $tmpList $essAgs]
    if {$argsFlag == 1} {
    puts "\n\n $procname: some essential args didn't set, please check. Test Stopped!"
    set ::ERRINFO  "$procname: some essential args didn't set, please check. "
        return $::FAILURE            
    }        
        
    
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -blockname      {set blockName $argx}
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }

        puts "Stop Flapping RouteBlock $blockName"
        set sg_routeRange $m_isisBlockArray($blockName)
        ixNet setAttribute $sg_routeRange -enabled False
        ixNet commit

}



#====================================================================
# ��������:GetRouterStats
# ������д: ��׿ 2009.5.4
# ��������: ��ȡIsis���ͳ�ƽ��
#
# �������:
# ��������                 ����˵��                ��������       Ixia֧��
#L1HelloPacketReceived	�յ�L1��Hello��                           yes
#L2HelloPacketReceived	�յ�L2��Hello��                           yes
#PtopHelloPacketReceived�յ�PtoP��Hello��                         yes
#L1LspPacketReceived	�յ�L1��Lsp��                             yes
#L2LspPacketReceived	�յ�L2��Lsp��                             yes  
#L1CsnpPacketReceived	�յ�L1��CSNP��                            yes
#L2CsnpPacketReceived	�յ�L2��CSNP��                            yes
#L1PsnpPacketReceived	�յ�L1��PSNP��                            yes
#L2PsnpPacketReceived	�յ�L2��PSNP��                            yes
#L1DatabaseSizeAdded	L1���ݿ�����                              no
#L2DatabaseSizeAdded	L2���ݿ�����                              no
#L1HelloPacketSent	����L1��Hello��                           yes
#L2HelloPacketSent	����L2��Hello��                           yes
#PtopHelloPacketSent	����PtoP��Hello��                         yes
#L1LspPacketSent	����L1��Lsp��                             yes
#L2LspPacketReceived	����L2��Lsp��                             yes
#L1CsnpPacketSent	����L1��CSNP��                            yes
#L2CsnpPacketSent	����L2��CSNP��                            yes 
#L1PsnpPacketSent	����L1��PSNP��                            yes
#L2PsnpPacketSent	����L2��PSNP��                            yes
#L1DatabaseSizeRemoved	L1���ݿ����                              no
#L2DatabaseSizeRemoved	L2���ݿ����                              no

#
# �﷨����:                                                         
#    isis1 GetRouterStats �CL1LspPacketReceived num
#
# ����ֵ��                                                          
#    ��ӡÿ����ѡ������ֵ,�籾����Ӧ�ô�ӡ
#   L1LspPacketReceived is 10

#
# Ixia Internal Use only
#i=0, "L2 Sess. Configured" MyValue: 1
#i=1, "L2 Sess. Up" MyValue: 1
#i=2, "L2 Init State Count" MyValue: 0
#i=3, "L2 Full State Count" MyValue: 1
#i=4, "L2 Neighbors" MyValue: 1
#i=5, "L2 DB Size" MyValue: 3
#i=6, "L2 Hellos Rx" MyValue: 357
#i=7, "L2 PTP Hellos Rx" MyValue: 0
#i=8, "L2 LSP Rx" MyValue: 5
#i=9, "L2 CSNP Rx" MyValue: 105
#i=10, "L2 PSNP Rx" MyValue: 0
#i=11, "L2 Hellos Tx" MyValue: 116
#i=12, "L2 PTP Hellos Tx" MyValue: 0
#i=13, "L2 LSP Tx" MyValue: 3
#i=14, "L2 CSNP Tx" MyValue: 0
#i=15, "L2 PSNP Tx" MyValue: 0
#i=16, "L1 Sess. Configured" MyValue: 0
#i=17, "L1 Sess. Up" MyValue: 0
#i=18, "L1 Init State Count" MyValue: 0
#i=19, "L1 Full State Count" MyValue: 0
#i=20, "L1 Neighbors" MyValue: 0
#i=21, "L1 DB Size" MyValue: 0
#i=22, "L1 Hellos Rx" MyValue: 0
#i=23, "L1 PTP Hellos Rx" MyValue: 0
#i=24, "L1 LSP Rx" MyValue: 0
#i=25, "L1 CSNP Rx" MyValue: 0
#i=26, "L1 PSNP Rx" MyValue: 0
#i=27, "L1 Hellos Tx" MyValue: 0
#i=28, "L1 PTP Hellos Tx" MyValue: 0
#i=29, "L1 LSP Tx" MyValue: 0
#i=30, "L1 CSNP Tx" MyValue: 0
#i=31, "L1 PSNP Tx" MyValue: 0
#                    
#====================================================================
itcl::body IsisRouter::GetRouterStats {args} {

    ixDebugPuts "Enter proc IsisRouter::GetRouterStats...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    #�����Ƕ������е�args������,Ȼ���ӡÿ��args��ʵ�ʵ�ֵ.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    set statViewList [ixNet getList [ixNet getRoot]/statistics \
                      statViewBrowser]

    set ProtoStats [lindex $statViewList 4]
    set state [ixNet getAttr $ProtoStats -enabled]
    ixNet setAttr $ProtoStats -enabled true
    ixNet commit


    set state [ixNet getAttr $ProtoStats -enabled]
    #puts "traffic stats state after enabling = $state"
    if {$state != "true" } {
        puts "Get ProtoStats stats failed!"
        return 1
    }
    #set last_page_no [ixNet getAttr $ProtoStats -totalPages]
    ixNet setAttr $ProtoStats -currentPageNumber 0
    ixNet commit

    set Curpage [ixNet getAttr $ProtoStats -currentPageNumber]
    #puts "Current page is : $Curpage"
    set row [lindex [ixNet getList $ProtoStats row] 0]
    
    for {set i 0} {$i<32} {incr i} {    
    set MyObj [lindex [ixNet getList $row cell] $i]  
    set SConfig [ixNet getAttr $MyObj -statValue]
    puts "$i Object:$MyObj Value:$SConfig"
    }
    
    #set MyObj [lindex [ixNet getList $row cell] 22]  
    #set SConfig [ixNet getAttr $MyObj -statValue]
    #puts "l1hellopacketreceived: $SConfig"


    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set value [lindex $args [expr $idxxx + 1]]
        case $cmdx      {
             -l1hellopacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 22]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig                
                }
             -l2hellopacketreceived        {
                set MyObj [lindex [ixNet getList $row cell] 6]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig 
             }
             -ptophellopacketreceived      {
                set MyObj [lindex [ixNet getList $row cell] 7]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig 
             }
             -l1lsppacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 24]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             } 
             -l2lsppacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 5]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l1csnppacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 25]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l2csnppacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 9]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l1psnppacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 26]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l2psnppacketreceived {
                set MyObj [lindex [ixNet getList $row cell] 10]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l1hellopacketsent {
                set MyObj [lindex [ixNet getList $row cell] 27]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l2hellopacketsent {
                set MyObj [lindex [ixNet getList $row cell] 11]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -ptophellopacketsent {
                set MyObj [lindex [ixNet getList $row cell] 12]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l1lsppacketsent {
                set MyObj [lindex [ixNet getList $row cell] 29]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l2lsppacketsent {
                set MyObj [lindex [ixNet getList $row cell] 13]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l1csnppacketsent {
                set MyObj [lindex [ixNet getList $row cell] 25]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l2csnppacketsent {
                set MyObj [lindex [ixNet getList $row cell] 14]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l1psnppacketsent {
                set MyObj [lindex [ixNet getList $row cell] 31]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -l2psnppacketsent {
                set MyObj [lindex [ixNet getList $row cell] 15]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }  
             default     {
                          puts "Error : No such option, please check input"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
}



#====================================================================
# ��������:GraceRestartAction
# ������д: ��׿ 
# ��������:����IsisRouter ��GR���ܣ���������
# �������: ��
# �﷨����:                                                         
#    IsisRouter GraceRestartAction
# ����ֵ��                                                          
#    �ɹ�0��ʧ��1��                         
#====================================================================
itcl::body IsisRouter::GraceRestartAction {args} {
        
    ixDebugPuts "Enter proc IsisRouter::GraceRestartAction...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {         
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    set sg_router $m_ixRouterId    
    ixNet setAttribute $sg_router -enableHitlessRestart True
    ixNet setAttribute $sg_router -restartMode helperRouter 
    ixNet setAttribute $sg_router -restartTime 30 
    ixNet setAttribute $sg_router -restartVersion version4 
    ixNet commit
    ixDebugPuts "Start Hitless restart..."
}

#δͨ��
#====================================================================
# ��������: AdvertiseRouters
# ������д: ��׿ 2009.4.23
# ��������: ͨ��ISIS����·����,Ixia����:�����û�ָ�����Ѿ�������ISIS Grid������ʹ�ܲ��㲥·��.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# RouterNameList  �Ѿ����ڵ�ISIS·�ɿ�����Ʊ�ʶ ��ѡ	     ��        ֧��     
#
# �﷨����:                                                         
#      IsisRouter AdvertiseRouters  -RouterNameList {grid1 grid2}
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::AdvertiseRouters {args} {
    ixDebugPuts "Enter proc IsisRouter::AdvertiseRouters...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routernamelist ""

    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routernamelist {set routerNameList $argx}      
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }
    
    
    
     for {set i 0} {$i < [llength $routerNameList]} {incr i} {
        set gridName [lindex $routerNameList $i]
        set sg_networkRange $m_isisGridArray($gridName)
        ixNet setAttribute $sg_networkRange -enabled True
        ixNet commit
     }

    puts "Fininshed!"
    
}

#δͨ��
#====================================================================
# ��������: WithdrawRouters
# ������д: ��׿ 2009.4.23
# ��������:  ����ISIS����·����,Ixia����:�����û�ָ�����Ѿ�������ISIS Grid����������·��.
# �������:
# ��������              ����˵��                  ��������    Ĭ��ֵ   Ixia֧��     
# RouterNameList  �Ѿ����ڵ�ISIS·�ɿ�����Ʊ�ʶ ��ѡ	     ��        ֧��     
#
# �﷨����:                                                         
#      IsisRouter WithdrawRouters  -RouterNameList {grid1 grid2}
# ����ֵ��                                                          
#                    
#====================================================================
itcl::body IsisRouter::WithdrawRouters {args} {
    ixDebugPuts "Enter proc IsisRouter::WithdrawRouters...\n"
    #��������������Ǹ����û���Ҫ�� "���벻���ִ�Сд",���Խ����е�args�����붼ת��ΪСд��.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #������������ǻ�ȡ��ǰ�Ĺ�����.
    set procname [lindex [info level [info level]] 0]  
    
    #��ȡ������������и�ֵ
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #���������趨����Ĭ��ֵ
    set routernamelist ""
    
    #�����Ƕ������е�args��ֵ,������������ʱ����.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set argx [lindex $args [expr $idxxx + 1]]

        case $cmdx      {
             -routernamelist {set routerNameList $argx}      
             default     {
                          puts "Error : cmd option $cmdx does not exist"
                         }
        }
        incr idxxx  +2
        incr tmpllength -2
        }    
     for {set i 0} {$i < [llength $routerNameList]} {incr i} {
        set gridName [lindex $routerNameList $i]
        set sg_networkRange $m_isisGridArray($gridName)
        ixNet setAttribute $sg_networkRange -enabled False
        ixNet commit
     }

    puts "Fininshed!"    
}






#====================================================================
# ��������: StartISISRouter
# ������д: ��׿ 2009.4.8
# ��������: ��ʼָ����Router��·�ɷ���
#           
# �������: ��  
#
# �﷨����:                                                         
#      IsisRouter StartISISRouter
#====================================================================

itcl::body IsisRouter::StartISISRouter {} {
    ixDebugPuts "Enter proc IsisRouter::StartISISRouter...\n"
    ##ixNet exec start $m_isisRouter
    #after 5000
    #ixNet exec startAllProtocols
    #puts "Router(s) are starting, check status in DUT, then press enter to continue!"
    #gets stdin k
    #puts "Started...."
    
    #ser r [ixNet getRoot]
    #set vPortList [ixNet getList $r vport]
    after 5000
    ixTclNet::StartProtocols "isis"  $m_vportId
    
    
}

itcl::body IsisRouter::StopISISRouter {} {
    ixDebugPuts "Enter proc IsisRouter::StartISISRouter...\n"
    ixTclNet::StopProtocols "isis"  $m_vportId
}




}