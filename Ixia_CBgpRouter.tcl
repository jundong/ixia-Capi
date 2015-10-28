#====================================================================
# �汾�ţ�1.0
#   
# �ļ�����Ixia_CBgpRouter.tcl
# 
# �ļ�������IxiaCapi����Ripv4·����
# 
# ���ߣ�Sigma
#
# ����ʱ��: 2009.03.03
#
# �޸ļ�¼�� 
#   
# ��Ȩ���У�Ixia
#====================================================================

#====================================================================
# ������:                                                           
#    ::BgpRouter    by Sigma                                               
# ����:                                                               
#    ����Ϊ���࣬�������о���˿ڵĹ�ͬ���� 
#    ���ࣺ��                                                       
#    ���ࣺ����Ķ˿��࣬������̫���˿��ࡢ������·�˿����                                                      
#    ����ࣺЭ������ࡢ���������������ͳ�Ʒ���������                                         
# �﷨����:                                                         
#    TestDevice ipaddress                                           
#    �磺TestDevice Tester1 192.168.0.100                           
#====================================================================
package require Thread
namespace eval IxiaCapi {
    
itcl::class BgpRouter {
    namespace import ::IxiaCapi::*

    public variable m_portObjectId    ""    
    public variable m_chassisId       ""
    public variable m_slotId          ""
    public variable m_portId          ""
    public variable m_vportId          ""
    public variable m_routerType      ""
    public variable m_routerId        ""
    public variable m_this            ""
    public variable m_namespace       ""
    public variable m_bgpId           ""
    public variable m_intfId          ""
    public variable m_intfIpv4Id      ""
    public variable m_intfMac         "00 00 00 00 00 01"
    public variable m_intfv4Ip        "192.168.1.2"
    public variable m_intfv4IpMask    "24"
    public variable m_intfv4Gateway   "192.168.1.1"
    public variable m_neighborRange_parameter_default() ""
    public variable m_sg_neighborRange ""
    public variable m_routerblock_name {}
    public variable m_vpn_routerblock_name {}
    public variable m_mpls_name {}
    public variable m_mpls_type ""
    public variable m_sg_l3Site
    public variable m_WADTimer 500
    public variable m_AWDTimer 500
    public variable m_thread_id ""
    public variable m_route_vpn_arrays {}
    public common   m_bgpArgsArray
    public variable m_ixRouterId
    public variable m_BlockArray
    set m_bgpArgsArray(testip)  "192.85.1.1"
     
    inherit Router
    constructor {portobj routertype {routerid 192.168.1.1}} \
    {Router::constructor $portobj $routertype $routerid} {
        set m_portObjectId $portobj
        set m_chassisId [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_chassisId]
        set m_slotId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_slotId]
        set m_portId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_portId]
        set vport [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_vportId]
        set m_vportId $vport
        set m_routerType $routertype
        set m_routerId  $routerid
        set m_this      [namespace tail $this]
        set m_namespace [namespace qualifiers $this]
        set IxiaCapi::namespaceArray($m_this,namespace) $m_namespace

        ixNet setAttribute $vport/protocols/ping -enabled True
        ixNet setAttribute $vport/protocols/arp -enabled True
        ixNet setAttribute $vport/protocols/bgp -enabled True
        ixNet setAttribute $vport/protocols/bgp -enableExternalActiveConnect True
        ixNet setAttribute $vport/protocols/bgp -enableInternalActiveConnect True
        ixNet setAttribute $vport/protocols/bgp -externalRetries 0
        ixNet setAttribute $vport/protocols/bgp -externalRetryDelay 120
        ixNet setAttribute $vport/protocols/bgp -internalRetries 0
        ixNet setAttribute $vport/protocols/bgp -internalRetryDelay 120
             
        set m_ixRouterId [ixNet add $m_vportId/protocols/bgp neighborRange]
        set intfList [ixNet getList $m_vportId interface]
        foreach intf $intfList {
            set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
             if {$ipaddr == $m_bgpArgsArray(testip)} {
                set m_intfId $intf
                ixNet setAttribute $m_ixRouterId -localIpAddress $m_intfId
                ixNet commit
                break
            }
        }
        set m_ixRouterId [ixNet remapIds $m_ixRouterId]
        ixNet commit
    }
    
    destructor {
    }

    public method ConfigRouter
    public method ConfigCapability
    public method GetBgpCapability
    public method GetRouter
    public method Enable
    public method Disable  
    public method ConfigRouteBlock
    public method AdvertiseRouteBlock
    public method WithdrawRouteBlock
    public method FlapRouteBlock
    public method ConfigRouterFlap 
    public method StopFlapRouteBlock
    public method GetAttributeList
    public method CommitIxNetParameter
    public method CreateRouteBlock    
    public method DeleteRouteBlock
    public method ListRouteBlock
    public method GetRouteBlock
    public method CreateVpnRouteBlock
    public method DeleteVpnRouteBlock
    public method ConfigVpnRouteBlock
    public method GetIxiaList
    public method StartFlapRouteBlock
    public method ConfigFlapRouteBlock
    public method DeleteMplsVpn
    public method ConfigMplsVpn
    public method CreateMplsVpn
    public method AddRouteBlockToVPN
    public method DeleteVpnRouteBlock_p
    public method ConfigVpnRouteBlock_p
    public method RemoveRouteBlockFromVPN
    public method GetRouterStats
    public method CheckArgs
    public method StartBGPRouter
    public method StopBGPRouter
}

#================================================================z====
# ��������:CommitIxNetParameter by sigma 2009.3.6                                                  
# ����: ���ݴ�������Ixia����ľ��, ����Ixia�ĸ���ģ��. 
# ����:
# list 1: Ixia����ľ��
# list 2: �ϼ������Ĳ���, 
# list 3: Ixia����Ĳ���list, ��������Ĭ�ϲ�����key
# list 4: �� list 2��Ӧ, ��Ҫ�޸ĵĲ���
# �﷨����:                                                         
#    CommitIxNetParameter $sg_neighborRange [array get m_neighborRange_parameter_default] \
#        [array get neighborRange_parameter_list] [array get args_array]
# ����ֵ��                                                          
#    �ɹ�0��ʧ��1��                         
#====================================================================
itcl::body BgpRouter::CommitIxNetParameter {args} {
    set procname [lindex [info level [info level]] 0]
    set ActionType [lindex $args 0]
    set ArgsDef [lindex $args 1]
    set ArgsPara [lindex $args 2]

    set remaps ""
    if {[llength $args] == 5} {
        
        set remaps [lindex $args 4]
    }

    set args [lindex $args 3]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }       
    if {[catch {array set ArrayPara $ArgsPara} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }    
    if {[catch {array set ArrayDef $ArgsDef} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }    

    #�ó�����������������в���, �������Ĭ�ϲ�����list, ȡ��Ĭ�ϲ���
    #----------------------------------------------------------------
    foreach {para_key ixNet_key} [array get ArrayPara] {        
        if {$ixNet_key == "NULL"} {
            set ::ERRINFO "No such args $para_key supported."
            continue
        }
        if {[info exists args_array($para_key)]} {
            set ArrayDef($ixNet_key) $args_array($para_key)
        } else {
            if {![info exists ArrayDef($ixNet_key)]} {
                set ::ERRINFO  "$procname: Miss mandatory arg $ixNet_key."
                continue
                #return $::FAILURE
            }
            
            if {$ArrayDef($ixNet_key) == "NULL"} {
                set ::ERRINFO  "$procname: Miss mandatory arg $ixNet_key."
                unset ArrayDef($ixNet_key)
                #return $::FAILURE
            }
        }
    }
    #ͨ��setAttribute�������в�����ixia
    #----------------------------------
    foreach {ix_key value} [array get ArrayDef] {
        ixNet setAttribute $ActionType $ix_key $value
    }
    
    ixNet commit
    
    if {$remaps == no} {
        return $ActionType
    }
    set sg_neighborRange [lindex [ixNet remapIds $ActionType] 0]
    return $sg_neighborRange

}

#====================================================================
# ��������:ConfigRouter by sigma 2009.3.6                                                             
# ����:����BGP Router�Ĺ���ģʽ
# ����:
# PeerType:             Ibgp/ebgp/multihop/vpn_internal /vpn_external/�� ��ѡ    ֧��
# TesterIp:             Э�����Ĳ�����IP��ַ ��ѡ	                             ֧��
# TesterAs:             Tester ��AS��	��ѡ                                       ֧��
# SutIp:                �����豸��IP��ַ ��ѡ	                                  ֧��
# SutAs:                �����豸��AS�� ��ѡ	                                     ��֧�� 
# FlagMd5:              �Ƿ�MD5��֤ ��ѡ	                                       ֧��
# Md5:                  MD5��ֵ ��ѡ	                                           ֧��
# ErrorCode:            ����notification���ĵ�ԭ�� ��ѡ	                        ֧��
# ErrorSubcode:         notify��ϸ��ԭ�� ��ѡ	                                  ֧��
# HoldTimer:            BGP�ھӵı���ʱ�� ��ѡ	                                  ֧��
# KeepaliveTimer:       ����Keepalive��Ϣ��ʱ����	��ѡ	                      ��֧��
# ConnectRetryTimer:    ���Ͳ��ɹ������Դ���	��ѡ	                             ��֧��
# RoutesPerUpdate:      ��ѡ	                                                   ֧��
# InterUpdateDelay:     ��ѡ	                                                   ֧��
# FlagEndOfRib:         ��ѡ	                                                   ��֧��
# StartingLabel:        VPN��ǩ����ʼֵ ��ѡ 16                                  ��֧��
# EndingLabel:          VPN��ǩ�����ֵ ��ѡ Ĭ��ΪЭ��涨�����ֵ              ��֧��
# Active:               BgpRouter�Ƿ񼤻� ��ѡ	                                 ֧��
# �﷨����:                                                         
#    <obj> ConfigRouter -SutIp 1.1.1.1 -TestIp 1.1.1.2 -Active true                               
# ����ֵ��                                                          
#    FAILED or SUCCESSED                         
#====================================================================
itcl::body BgpRouter::ConfigRouter {args} {
    ixDebugPuts "Enter proc BgpRouter::ConfigRouter...\n"
    set args [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
   
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }  
    
    if {![info exists args_array(-testerip)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -TestIp."
        return $::FAILURE      
    } else {
       
        #��testip������interface��ip���бȽ�
        #��ipһ������Ϊrouter��ģ��ӿ�
        #-----------------------------------
        set m_bgpArgsArray(testip) $args_array(-testerip)
        set intfList [ixNet getList $m_vportId interface]
        foreach intf $intfList {
            set ipaddr [ixNet getAttribute $intf/ipv4 -ip]
            if {$ipaddr == $args_array(-testerip)} {
                set m_intfId $intf
                break
            }             
        }
        if {$m_intfId == ""} {
            set ::ERRINFO "$procname: No such interface with ip address $args_array(-testerip) defined."
            puts "$procname: No such interface with ip address $args_array(-testerip) defined."
            return $::FAILURE     
        }
    }
    
    #����neighborRange��Ĭ�ϲ���array
    #--------------------------------
    array set m_neighborRange_parameter_default {-asNumMode fixed -authentication null\
        -bfdModeOfOperation multiHop -bgpId {100.1.0.1} -dutIpAddress {20.20.20.1}\
        -enable4ByteAsNum False -enableActAsRestarted False -enableBfdRegistration False\
        -enableBgpId True -enableGracefulRestart False -enableNextHop False \
        -enableOptionalParameters False -enableStaggeredStart False -enabled True\
        -holdTimer 90 -ipV4Mdt False -ipV4Mpls True -ipV4MplsVpn True -ipV4Multicast True\
        -ipV4Unicast True -ipV6Mpls True -ipV6MplsVpn True -ipV6Multicast True\
        -ipV6Unicast True -localAsNumber 65001 -localIpAddress {20.20.20.2} -md5Key {}\
        -nextHop 0.0.0.0 -numUpdatesPerIteration 1 -rangeCount 1 -remoteAsNumber 0\
        -restartTime 45 -staggeredStartPeriod 0 -staleTime 0 -tcpWindowSize 8192\
        -ttlValue 64 -type internal -updateInterval 0 -vpls False}
    
    
    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set neighborRange_parameter_list {-peertype -type -testerip \
        -localIpAddress -sutip -dutIpAddress -testeras -localAsNumber -sutip -dutIpAddress \
        -sutas NULL -flagmd5 -authentication -md5 -md5Key -errorcode NULL -errorsubcode \
        NULL -holdtimer -holdTimer -keepalivetimer NULL -connectretrytimer NULL \
        -routesperupdate -updateInterval -interupdatedelay -numUpdatesPerIteration \
        -flagendofrib NULL -startinglabel NULL -endinglabel NULL -active -enabled}   
    
    if {[CheckArgs $procname [array get neighborRange_parameter_list] [array get args_array]] == 0} {
        return $::FAILURE 
    }     

    #��ȡneighborRange��object
    #-------------------------
    set sg_neighborRange $m_ixRouterId  
    
    #�����õ���Ixia
    set m_sg_neighborRange [CommitIxNetParameter $sg_neighborRange [array get m_neighborRange_parameter_default] \
        [array get neighborRange_parameter_list] [array get args_array]]
    return $::SUCCESS 
}

#====================================================================
# ��������:Enable by sigma 2009.3.6                                                  
# ����: ʹ��ָ����Bgp Router 
# ����:
# �﷨����:                                                         
#    <obj> Enable
# ����ֵ�� 
#    �����ǳɹ����� Bgpv6Router�����򷵻�1�����򷵻�0��                         
#====================================================================
itcl::body BgpRouter::Enable {args} {
    ixDebugPuts "Enter proc BgpRouter::Enable...\n" 
    ixNet setAttribute $m_sg_neighborRange -enabled True
    ixNet commit
    set m_sg_neighborRange [ixNet remapIds $m_sg_neighborRange]
    return $::SUCCESS 
    #ixNet exec startAllProtocols
    #return $::SUCCESS
}

#====================================================================
# ��������:Disable by sigma 2009.3.6                                                  
# ����: �ر�ָ����Bgp Router
# ����:
# �﷨����:                                                         
#    <obj> Disable
# ����ֵ��                                                          
#    �����ǳɹ�ֹͣ Bgpv6Router�����򷵻�1�����򷵻�0��                    
#====================================================================
itcl::body BgpRouter::Disable {args} {
    ixDebugPuts "Enter proc BgpRouter::Disable...\n"
    ixNet setAttribute $m_sg_neighborRange -enabled False
    ixNet commit
    set m_sg_neighborRange [ixNet remapIds $m_sg_neighborRange]
    return $::SUCCESS   
    #ixNet exec stopAllProtocols
    #return $::SUCCESS
}

#====================================================================
# ��������:ConfigCapability by Shawn Li 2009.2.9                                                  
# ����:����BGP Router�Ĺ���ģʽ
# ����:
# IPv4           Enable/disable    ��ѡ     ֧��
# IPv6           Enable/disable    ��ѡ     ֧��
# VPNv4          Enable/disable    ��ѡ     ֧��
# VPNv6          Enable/disable    ��ѡ     ֧��
# LabeledIPv4    Enable/disable    ��ѡ     ֧��
# LabeledIPv6    Enable/disable    ��ѡ     ֧��
# IPv4Multicast  Enable/disable    ��ѡ     ֧��
# IPv6Multicast  Enable/disable    ��ѡ     ֧��
# VPLS           Enable/disable    ��ѡ     ֧��
# MVPN           Enable/disable    ��ѡ     ��֧��
# RouterRefresh  Enable/disable    ��ѡ     ��֧��
# Grace Restart  Enable/disable    ��ѡ     ֧��
# CooperativeFiltering    Enable/disable    ��֧�� ��ѡ
# AsCapability                              ��֧��
# UserDefined    ֧�����    ��ѡ           ��֧��
# �﷨����:                                                         
#    <obj> ConfigCapability -VPNv4 False                                      
# ����ֵ��                                                          
#    FAILED or SUCCESSED                         
#====================================================================
itcl::body BgpRouter::ConfigCapability {args} {
    ixDebugPuts "Enter proc BgpRouter::ConfigCapability...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    #����neighborRange��Ĭ�ϲ���array
    #--------------------------------
    array set neighborRange_parameter_default {-ipV4Mdt False -ipV4Mpls True \
        -ipV4MplsVpn True -ipV4Multicast True -ipV4Unicast True -ipV6Mpls True \
        -ipV6MplsVpn True -ipV6Multicast True -ipV6Unicast True -updateInterval 0 \
        -vpls False -enableGracefulRestart False}
    
    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set neighborRange_parameter_list {-ipv4 -ipV4Unicast -ipv6 -ipV6Unicast -vpnv4 -ipV4MplsVpn \
        -vpnv6 -ipV6MplsVpn -labeledipv4  -ipV4Mpls -labeledipv6  -ipV6Mpls -ipv4multicast -ipV4Multicast \
        -ipv6multicast -ipV6Multicast -vpls -vpls -mvpn NULL -routerrefresh NULL -gracerestart \
        -enableGracefulRestart -cooperativefiltering NULL -ascapability NULL -userdefined  NULL}
    
    if {[CheckArgs $procname [array get neighborRange_parameter_list] [array get args_array]] == 0} {
        return $::FAILURE 
    } 
    #��ȡneighborRange��object
    #-------------------------
    set sg_neighborRange $m_sg_neighborRange
    
    #�����õ���Ixia
    return [CommitIxNetParameter $sg_neighborRange [array get m_neighborRange_parameter_default] \
        [array get neighborRange_parameter_list]  [array get args_array] no] 
    return $::SUCCESS 
}

#====================================================================
# ��������:GetAttributeList by sigma 2009.3.6                                                  
# ����: ���ݴ�������Ixia����ľ��, ����Ixia�ĸ���ģ��. 
# ����:
# list 1: Ixia����ľ��
# list 2: ��Ҫ��ȡ�Ĳ�����ɵ�list
# �﷨����:                                                         
#    GetAttributeList $sg_neighborRange [array get neighborRange_parameter_list]
# ����ֵ��                                                          
#    ���ض�Ӧ��array                        
#====================================================================
itcl::body BgpRouter::GetAttributeList {args} {
    set procname [lindex [info level [info level]] 0]
    set ActionType [lindex $args 0]
    set args [ixConvertToLowerCase $args]
    
    set args [lindex $args 1]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }    
    #ͨ��getAttribute�������в�����ixia
    #----------------------------------
    array set result {}    
    foreach {para_key ixNet_key} [array get args_array] {
        if {$ixNet_key == "NULL"} {
            set result($para_key) "NULL"
            continue
        }
        set result($para_key) [ixNet getAttribute $ActionType $ixNet_key]
       
    }
    
    return [array get result]
}

#====================================================================
# ��������:GetAttributeList by sigma 2009.3.6                                                  
# ����: ���ݴ�������Ixia����ľ��, ����Ixia�ĸ���ģ��. 
# ����:
# list 1: Ixia����ľ��
# list 2: ��Ҫ��ȡ�Ĳ�����ɵ�list
# �﷨����:                                                         
#    GetAttributeList $sg_neighborRange [array get neighborRange_parameter_list]
# ����ֵ��                                                          
#    ���ض�Ӧ��array                        
#====================================================================
itcl::body BgpRouter::GetIxiaList {args} {
    set procname [lindex [info level [info level]] 0]
    set ActionType [lindex $args 0]
    set args [lindex $args 1];
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }    
    
    #ͨ��getAttribute�������в�����ixia
    #----------------------------------
    array set result {}    
    foreach {para_key ixNet_key} [array get args_array] {
        if {$ixNet_key == "NULL"} {
            set result($para_key) "NULL"
            continue
        }
        set result($ixNet_key) [ixNet getAttribute $ActionType $ixNet_key]
    }
    
    return [array get result]
}

#====================================================================
# ��������:GetBgpCapability by sigma 2009.3.6
# ����:  ����Bgp Router Session����ز�������ʾ��session��Capability
# ����:
# IPv4           Enable/disable    ��ѡ     ֧��
# IPv6           Enable/disable    ��ѡ     ֧��
# VPNv4          Enable/disable    ��ѡ     ֧��
# VPNv6          Enable/disable    ��ѡ     ֧��
# LabeledIPv4    Enable/disable    ��ѡ     ֧��
# LabeledIPv6    Enable/disable    ��ѡ     ֧��
# IPv4Multicast  Enable/disable    ��ѡ     ֧��
# IPv6Multicast  Enable/disable    ��ѡ     ֧��
# VPLS           Enable/disable    ��ѡ     ֧��
# MVPN           Enable/disable    ��ѡ     ��֧��
# RouterRefresh  Enable/disable    ��ѡ     ��֧��
# Grace Restart  Enable/disable    ��ѡ     ֧��
# CooperativeFiltering    Enable/disable    ��֧�� ��ѡ
# AsCapability                              ��֧��
# UserDefined    ֧�����    ��ѡ           ��֧��
# �﷨����:                                                         
#    <obj> GetBgpCapability  -ipv4 ipv4 -ipv6 ipv6 -vpnv4 vpnv4 
# ����ֵ��                                                          
#    FAILED or SUCCESSED                           
#====================================================================
itcl::body BgpRouter::GetBgpCapability {args} {
    ixDebugPuts "Enter proc BgpRouter::GetBgpCapability...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #��ȡneighborRange��object
    #-------------------------
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_neighborRange $m_sg_neighborRange

    #������Ҫ��neighborRange��ȡ��Ϣ��array
    #--------------------------------------
    array set neighborRange_parameter_list {-ipv4 -ipV4Unicast -ipv6 -ipV6Unicast -vpnv4 -ipV4MplsVpn \
        -vpnv6 -ipV6MplsVpn -labeledipv4  -ipV4Mpls -labeledipv6  -ipV6Mpls -ipv4multicast -ipV4Multicast \
        -ipv6multicast -ipV6Multicast -vpls -vpls -mvpn NULL -routerrefresh NULL -gracerestart \
        -enableGracefulRestart -cooperativefiltering NULL -ascapability NULL -userdefined  NULL}
  
    if {[CheckArgs $procname [array get neighborRange_parameter_list] [array get args_array]] == 0} {
        return $::FAILURE 
    } 
        
    #��ʼ��ȡ
    #--------
    array set result [GetAttributeList $sg_neighborRange [array get neighborRange_parameter_list]]
    foreach {key value} [array get args_array] {
        uplevel 1 "set $value $result($key)"
    } 
    return $::SUCCESS
}

itcl::body BgpRouter::CheckArgs {args} {
    set procname [lindex $args 0]
    set parameter [lindex $args 1]
    set array [lindex $args 2]
    if {[catch {array set parameters $parameter} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILED
    }    
    if {[catch {array set arrays $array} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILED
    }    
    
    foreach {key value} [array get arrays] {   
        if {![info exists parameters($key)]} {
            set ::ERRINFO  "$procname: No such args $key supported."
            puts "$procname: No such args $key supported."
            return 0
        }
        
        if {$parameters($key) == "NULL"} {
            set ::ERRINFO  "$procname: No such args $key supported."
            puts "$procname: No such args $key supported."
            return 0
        }
    }
    return 1
}
    
#====================================================================
# ��������:GetRouter by sigma 2009.3.6
# ����: ��ȡBgpRotuer��������Ϣ
# ����:  
#   PeerType	Ibgp/ebgp/multihop/vpn_internal /vpn_external/multihop��	��ѡ   ֧��
#   TesterIp	Э�����Ĳ�����IP��ַ	��ѡ                                    ֧��
#   PrefixLen	Э������ַ�����볤��	��ѡ                                     ֧��
#   TesterAs	Tester ��AS��	��ѡ                                              ֧��
#   SutIp	�����豸��IP��ַ	��ѡ                                               ֧��
#   SutAs	�����豸��AS��	��ѡ                                                ��֧��
#   FlagMd5	�Ƿ�MD5��֤	��ѡ                                                  ֧��
#   Md5	MD5��ֵ	��ѡ                                                          ֧��
#   FlagLdp	�Ƿ��ڲ����Ǻͱ����豸֮�佨��LDP	��ѡ                           ��֧��
#   ErrorCode	����notification���ĵ�ԭ��	��ѡ                                 ��֧��
#   ErrorSubcode	notify��ϸ��ԭ��	��ѡ                                       ��֧��
#   HoldTimer	 BGP�ھӵı���ʱ��	��ѡ                                         ֧��
#   KeepaliveTimer	����Keepalive��Ϣ��ʱ����	��ѡ                         ��֧��
#   ConnectRetryTimer	 ���Ͳ��ɹ������Դ���	��ѡ                              ��֧��
#   RoutesPerUpdate	 ÿ�θ��µ�·��������1-2000��	��ѡ                       ֧��
#   InterUpdateDelay	 ���͸���·�ɵļ��ʱ��	��ѡ                           ֧��
#   FlagEndOfRib		��ѡ                                                      ��֧��
#   FlagLabelRouteCapture		��ѡ                                              ��֧��
#   Active		��ѡ                                                            ֧��
#   State	BgpRouter��״̬����ö�����£�                                       ֧��
#   DISABLED|CLOSED|OPENNING|ESTABLISHED(��ΪN2X��OPEN)|UPDATING	��ѡ
#
# �﷨����:
#    <obj> GetRouter -peettype type -testerip testerip
# ����ֵ��                                                          
#    FAILED or SUCCESSED                           
#====================================================================
itcl::body BgpRouter::GetRouter {args} {
    ixDebugPuts "Enter proc BgpRouter::GetRouter...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    #��ȡneighborRange��object
    #-------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    set sg_neighborRange $m_sg_neighborRange

    #������Ҫ��neighborRange��ȡ��Ϣ��array
    #--------------------------------------
    array set neighborRange_parameter_list {-peertype -type -testerip -localIpAddress 
        -sutip -dutIpAddress -testeras -localAsNumber -sutip -dutIpAddress -sutas NULL \
        -flagmd5 -authentication -md5 -md5Key -errorcode NULL -errorsubcode NULL -holdtimer -holdTimer \
        -keepalivetimer NULL -connectretrytimer NULL -routesperupdate -updateInterval \
        -interupdatedelay -numUpdatesPerIteration -flagendofrib NULL -flaglabelroutecapture NULL \
        -active -enabled -flagldp NULL}
        
    array set result [GetAttributeList $sg_neighborRange [array get neighborRange_parameter_list]]
    
    set result(-prefixlen) [ixNet getAttribute $m_intfId/ipv4 -maskWidth]
    set result(-state) [ixNet getAttribute $m_vportId/protocols/rip -runningState]
    
    set neighborRange_parameter_list(-prefixlen) "1"
    set neighborRange_parameter_list(-state) "1"
    
    if {[CheckArgs $procname [array get neighborRange_parameter_list] [array get args_array]] == 0} {
        return $::FAILURE 
    } 
        
    #��ʼ��ȡ
    #--------    
    foreach {key value} [array get args_array] {
        uplevel 1 "set $value $result($key)"
    } 
    return $::SUCCESS
}

#====================================================================
# ��������:CreateRouteBlock by sigma 2009.3.6
# ����: ��Bgp Router��·�ɿ�
# ����:
#    BlockName	    RouteBlock����	                ��ѡ   ֧��
#    AddressFamily	IPv4 or IPv6	                         ֧��
#    FirstRoute	    RouteBlock����ʼ��ַ          	��ѡ    ֧��
#    PrefixLen	    RouteBlock��ǰ׺����         	��ѡ    ֧��
#    RouteNum	    RouteBlock����Ŀ����           	��ѡ    ֧��
#    Modifier	    RouteBlock�ı仯����	            ��ѡ    ֧��
#    Active	        �򿪻�ر�·�ɳ� enable/disable	       ֧��
#    AS_SEQUENCE	    ��˳���ɵ�AS �ż���	      ��ѡ    ֧��
#    AS_SET	        δ��˳���ɵ� AS�ż���	       ��ѡ    ֧��
#    AS_PATH	        �б����ԣ�                           ֧��
#    CONFEED_SEQUENCED	 ���˵�AS�� 	             ��ѡ    ֧��
#    CONFEED_SET	 	                               ��ѡ    ֧��
#    ORIGIN	        ���ϱ�ѡ���ԣ�                         ֧��
#                   0/1/2 EGP/IGP/INcomplete        ��ѡ
#    NEXT HOP	    ������Ŀ�ĵ�ַ��·����һ��	       ��ѡ    ��֧��
#    MED	            Ӱ������AS��ҵ��ԽСԽ���� 	��ѡ   ֧��
#    LOCAL_PREF	    �����ڱ���AS�ڣ�ֵԽ��Խ����   	��ѡ   ֧��
#    ATOMATIC_AGGREGATE	ԭ�Ӿۺ� ������Ǻ�������	��ѡ   ��֧��
#    AGGREGATOR_AS		                                ��ѡ   ֧��
#    AGGRGATOR_IPADDRESS		                          ��ѡ    ֧��
#    ORIGINATOR_ID	RRʹ�õģ���·�ɷ����߲�����һ��32���ص�ֵ��	��ѡ   ֧��
#    CLUSTER_LIST	RRʹ�õģ�·�ɾ�����������ID��һ����š�	   ��ѡ   ��֧�� 
#    COMMUNITIES	    ��������	                       ��ѡ   ֧��
#    Label	        �Ƿ�֧�� Label	                   ��ѡ   ��֧��
#    LabelMode	    ��ǩģʽ	                         ��ѡ   ��֧��
#    UserLabel		                                     ��ѡ   ��֧��
#    FlagAdvertise		                                        ��֧��
#    FlagTrafficDest	                                        ��֧��	
#    FlagFlap		                                              ��֧��
# �﷨����:
#    <obj> CreateRouteBlock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::CreateRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::CreateRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }

    if {[info exists m_BlockArray($args_array(-blockname))]} {
        set ::ERRINFO  "$procname: the name:$args_array(-blockname) already exist."
        return $::FAILURE
    }
    
    #����neighborRange��Ĭ�ϲ���array
    #--------------------------------
    array set routeRange_parameter_default {-aggregatorAsNum 0 -aggregatorIpAddress {0.0.0.0}\
        -enableAggregator True -enableAggregatorIdIncrementMode True -enableAsPath True\
        -enableAtomicAttribute True -enableCluster True -enableCommunity True \
        -enableGenerateUniqueRoutes True -enableIncludeLoopback True -enableIncludeMulticast\
        True -enableLocalPref True -enableMed True -enableNextHop True -enableOrigin True\
        -enableOriginatorId True -enableProperSafi False -enableTraditionalNlriUpdate True\
        -enabled False -fromPacking 0 -fromPrefix 24 -ipType ipv4 -iterationStep 1 -localPref 0\
        -med 0 -networkAddress {0.0.0.0} -nextHopIpAddress {0.0.0.0} -nextHopIpType ipv4\
        -nextHopMode nextHopIncrement -nextHopSetMode sameAsLocalIp -numRoutes 1\
        -originProtocol igp -originatorId {0.0.0.0} -thruPacking 0 -thruPrefix 24}
    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set routeRange_parameter_list {-aggregator_as -aggregatorAsNum\
          -aggrgator_ipaddress -aggregatorIpAddress -communities -enableCommunity\
          -prefixlen -thruPrefix -prefixlen -fromPrefix -addressfamily -ipType\
          -modifier -iterationStep -local_pref -localPref -med -med -firstroute -networkAddress\
          -routenum -numRoutes -origin -originProtocol -originator_id -originatorId\
          -blockname NULL -next_hops NULL -atomatic_aggregate NULL -label NULL -labelmode NULL\
          -userlabel NULL -flagadvertise NULL -flagtrafficdest NULL -flagflap NULL -active -enabled}
          
    set sg_routeRange [ixNet add $m_sg_neighborRange routeRange]
    
    set routerblock_name($args_array(-blockname)) [CommitIxNetParameter $sg_routeRange \
        [array get routeRange_parameter_default] [array get routeRange_parameter_list] [array get args_array]]
    
   if {[info exists args_array(-nexthop)]} {
        set sg_routeRange $routerblock_name($args_array(-blockname))
        ixNet setAttribute $sg_routeRange -nextHopSetMode setManually 
        ixNet setAttribute $sg_routeRange -nextHopMode nextHopIncrement
        ixNet setAttribute $sg_routeRange -nextHopIpType ipv4 
        ixNet setAttribute $sg_routeRange -nextHopIpAddress $args_array(-nexthop)  
        ixNet commit        
        set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]
    }
    
    set routeRange_parameter_as {-as_sequence asSequence -as_set asSet -confeed_sequenced \
        asConfedSequence  -confeed_set asConfedSet}
    
    set list_as {}
    foreach {para_key ixNet_key} [array get routeRange_parameter_as] {
        if {[info exists args_array($para_key)]} {
            lappend tmp True $ixNet_key $args_array($para_key)
            lappend list_as $tmp
            unset tmp
        }
    }
    set sg_routeRange $routerblock_name($args_array(-blockname))
    set t_list [array get routeRange_parameter_list]
    lappend t_list -as_sequence asSequence -as_set asSet -confeed_sequenced \
        asConfedSequence  -confeed_set asConfedSet -blockname a -nexthop t
    if {[CheckArgs $procname $t_list [array get args_array]] == 0} {
        return $::FAILURE 
    } 
    
    ixNet setAttribute $sg_routeRange/asSegment -asSegments $list_as
    ixNet commit
    set m_routerblock_name [array get routerblock_name]
    array set m_BlockArray $m_routerblock_name
    return $::SUCCESS
}

#====================================================================
# ��������:DeleteRouteBlock by sigma 2009.3.6
# ����: ɾ��Bgp Router��·�ɿ�
# ����:
#    BlockName	    RouteBlock����	��ѡ        ֧��
# �﷨����:
#    <obj> DeleteRouteBlock -BlockName xx
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::DeleteRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::DeleteRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO "deleteblock need input blockname"
        return $::FAILUR
    }    
    
    if {[array names m_BlockArray $args_array(-blockname)] ==""} {
        set ::ERRINFO "$procname: the name of router block not exist."
        return $::FAILURE
    }    
    #�ҳ���Ӧ��route block, ����ɾ��
    #------------------------------
    #array set routerblock_name $m_routerblock_name
    #ixNet remove $routerblock_name($args_array(-blockname))
    ixNet remove $m_BlockArray($args_array(-blockname))
    ixNet commit
    unset m_BlockArray($args_array(-blockname))
    #unset routerblock_name($args_array(-blockname))
    #set m_routerblock_name [array get routerblock_name]
    return $::SUCCESS    
}

#====================================================================
# ��������:ListRouteBlock by sigma 2009.3.6
# ����: �г�Bgp Router��·�ɿ�
# ����:
#    BlockName	    RouteBlock����	��ѡ
# �﷨����:
#    <obj> ListRouteBlock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::ListRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::ListRouteBlock"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }

    #ȡ�����list, ����upvar
    foreach {key value} [array get args_array] {
        upvar 1 $value $value
        set $value [array names m_BlockArray]
    }
    return $::SUCCESS
}
#====================================================================
# ��������:ConfigRouteBlock by sigma 2009.3.6
# ����: ����һ��Bgp Router·�ɿ�
# ����:
#    BlockName	    RouteBlock����	               ��ѡ   ֧��
#    AddressFamily	IPv4 or IPv6	                        ֧��
#    RouteIp	    RouteBlock����ʼ��ַ	           ��ѡ    ֧��
#    PrefixLen	    RouteBlock��ǰ׺����	         ��ѡ    ֧��
#    RouteNum	    RouteBlock����Ŀ����           	��ѡ    ֧��
#    RouteStep	    RouteBlock�ı仯����	         ��ѡ    ֧��
#    enable	        �򿪻�ر�·�ɳ� enable/disable 	    ֧��
#    AS_SEQUENCE	    ��˳���ɵ�AS �ż���	      ��ѡ   ֧��
#    AS_SET	        δ��˳���ɵ� AS�ż���	       ��ѡ   ֧��
#    AS_PATH	        �б����ԣ�                          ֧��
#    CONFEED_SEQUENCED	 ���˵�AS�� 	              ��ѡ  ֧��
#    CONFEED_SET	 	��ѡ                                  ֧��
#    ORIGIN	        ���ϱ�ѡ���ԣ�                        ֧��
#                   0/1/2 EGP/IGP/INcomplete        ��ѡ
#    NEXT HOP	    ������Ŀ�ĵ�ַ��·����һ��	       ��ѡ  ��֧��
#    MED	            Ӱ������AS��ҵ��ԽСԽ����	 ��ѡ   ֧��
#    LOCAL_PREF	    �����ڱ���AS�ڣ�ֵԽ��Խ����	    ��ѡ  ֧��
#    ATOMATIC_AGGREGATE	ԭ�Ӿۺ� ������Ǻ�������	��ѡ   ��֧��
#    AGGREGATOR_AS		                               ��ѡ   ֧��
#    AGGRGATOR_IPADDRESS		                          ��ѡ   ֧��
#    ORIGINATOR_ID	RRʹ�õģ���·�ɷ����߲�����һ��32���ص�ֵ�� ��ѡ   ֧��
#    CLUSTER_LIST	RRʹ�õģ�·�ɾ�����������ID��һ����š�	     ��ѡ   ��֧�� 
#    COMMUNITIES	    ��������	                      ��ѡ   ֧��
#    Label	        �Ƿ�֧�� Label	                  ��ѡ    ��֧��
#    LabelMode	    ��ǩģʽ	                        ��ѡ    ��֧��
#    UserLabel                                    		��ѡ    ��֧��
#    FlagAdvertise		��֧��
#    FlagTrafficDest	��֧��	
#    FlagFlap  		    ��֧��
# �﷨����:
#    <obj> ConfigRouteBlock -blockname xx -RouteIp 1.1.1.1
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::ConfigRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::ConfigRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }

    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    #���blockname�Ѿ�������
    #------------------------
    #array set routerblock_name $m_routerblock_name
    
    if {![info exists m_BlockArray($args_array(-blockname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    
    set sg_routeRange $m_BlockArray($args_array(-blockname))
    
    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set routeRange_parameter_list {-aggregator_as -aggregatorAsNum \
          -aggrgator_ipaddress -aggregatorIpAddress -communities -enableCommunity \
          -prefixlen -fromPrefix -prefixlen -thruPrefix -addressfamily -ipType \
          -routestep -iterationStep -local_pref -localPref -med -med -routeip \
          -networkAddress -routenum -numRoutes -origin -originProtocol \
          -originator_id -originatorId -nexthop -nextHopIpAddress -enable -enabled}
    
    set original_parameter_list [GetIxiaList $sg_routeRange \
        [array get routeRange_parameter_list]]

    set routerblock_name($args_array(-blockname)) [CommitIxNetParameter \
        $sg_routeRange $original_parameter_list [array get routeRange_parameter_list] \
        [array get args_array] no]

    set sg_routeRange $routerblock_name($args_array(-blockname)) 
    
    if {[info exists args_array(-nexthop)]} {
        set sg_routeRange $routerblock_name($args_array(-blockname))
        ixNet setAttribute $sg_routeRange -nextHopSetMode setManually 
        ixNet setAttribute $sg_routeRange -nextHopMode nextHopIncrement
        ixNet setAttribute $sg_routeRange -nextHopIpType ipv4 
        ixNet setAttribute $sg_routeRange -nextHopIpAddress $args_array(-nexthop)  
        ixNet commit        
        set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]
    }
    
    #����as sequence ����
    #--------------------
    set routeRange_parameter_as {-as_sequence asSequence -as_set asSet -confeed_sequenced \
        asConfedSequence  -confeed_set asConfedSet}
    set list_as {}

    foreach {para_key ixNet_key} [array get routeRange_parameter_as] {
        if {[info exists args_array($para_key)]} { 
            set as_list [ixNet getList $sg_routeRange/asSegment asSegment]
            foreach t as_list {
                ixNet remove $t
            }
        }
    }

    foreach {para_key ixNet_key} [array get routeRange_parameter_as] {
        if {[info exists args_array($para_key)]} {
            lappend tmp True $ixNet_key $args_array($para_key)
            lappend list_as $tmp
            unset tmp
        }
    }
    set t_list [array get routeRange_parameter_list]
    lappend t_list -as_sequence asSequence -as_set asSet -confeed_sequenced \
        asConfedSequence  -confeed_set asConfedSet -blockname a -nexthop t
    if {[CheckArgs $procname $t_list [array get args_array]] == 0} {
        return $::FAILURE 
    } 
    
    ixNet setAttribute $sg_routeRange/asSegment -asSegments $list_as
    
    set m_routerblock_name [array get routerblock_name]
    return $::SUCCESS
}

#====================================================================
# ��������:GetRouteBlock by sigma 2009.3.6
# ����: ��ȡһ��Bgp Router·�ɿ�������Ϣ
# ����:
#    BlockName	    RouteBlock����	          ��ѡ   ֧��
#    AddressFamily	IPv4 or IPv6	                   ֧��
#    RouteIp	    RouteBlock����ʼ��ַ     	��ѡ    ֧��
#    PrefixLen	    RouteBlock��ǰ׺����	    ��ѡ    ֧��
#    RouteNum	    RouteBlock����Ŀ����	      ��ѡ    ֧��
#    RouteStep	    RouteBlock�ı仯����	    ��ѡ    ֧��
#    enable	        �򿪻�ر�·�ɳ� enable/disable	 ֧��
#    AS_SEQUENCE	    ��˳���ɵ�AS �ż���	��ѡ    ֧��
#    AS_SET	        δ��˳���ɵ� AS�ż���	 ��ѡ    ֧��
#    AS_PATH	        �б����ԣ�                     ֧��
#    CONFEED_SEQUENCED	 ���˵�AS��        	 ��ѡ    ֧��
#    CONFEED_SET	 	                         ��ѡ    ֧��
#    ORIGIN	        ���ϱ�ѡ���ԣ�                   ֧��
#                   0/1/2 EGP/IGP/INcomplete ��ѡ
#    NEXT HOP	    ������Ŀ�ĵ�ַ��·����һ��	��ѡ    ��֧��
#    MED	            Ӱ������AS��ҵ��ԽСԽ����  	��ѡ   ֧��
#    LOCAL_PREF	    �����ڱ���AS�ڣ�ֵԽ��Խ����	    ��ѡ   ֧��
#    ATOMATIC_AGGREGATE	ԭ�Ӿۺ� ������Ǻ�������	��ѡ   ��֧��
#    AGGREGATOR_AS		                        ��ѡ   ֧��
#    AGGRGATOR_IPADDRESS		                  ��ѡ   ֧��
#    ORIGINATOR_ID	RRʹ�õģ���·�ɷ����߲�����һ��32���ص�ֵ�� ��ѡ   ֧��
#    CLUSTER_LIST	RRʹ�õģ�·�ɾ�����������ID��һ����š�	     ��ѡ   ��֧�� 
#    COMMUNITIES	    ��������	               ��ѡ  ֧��
#    Label	        �Ƿ�֧�� Label	           ��ѡ    ��֧��
#    LabelMode	    ��ǩģʽ	                 ��ѡ    ��֧��
#    UserLabel		                             ��ѡ    ��֧��
#    FlagAdvertise		                                 ��֧��
#    FlagTrafficDest	                                 ��֧��	
#    FlagFlap		                                       ��֧��
#   Advertise	�Ƿ��͸�·�ɿ�	                ��ѡ   ��֧��
#   Flap	�Ƿ��񵴸�·�ɿ�                             ��֧��
#   TrafficDest	�Ƿ�����������Ŀ�ĵ�ַ                 ��֧��
# �﷨����:
#    <obj> GetRouteBlock -peertype peertype -sutip sutip
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::GetRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::GetRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    if {[array names m_BlockArray $args_array(-blockname)] ==""} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    
    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set routeRange_parameter_list {-aggregator_as -aggregatorAsNum \
          -aggrgator_ipaddress -aggregatorIpAddress -communities -enableCommunity \
          -prefixlen -fromPrefix -prefixlen -thruPrefix -addressfamily -ipType \
          -routestep -iterationStep -local_pref -localPref -med -med -routeip \
          -networkAddress -routenum -numRoutes -origin -originProtocol \
          -originator_id -originatorId -next_hops -nextHopIpAddress \
          -atomatic_aggregate NULL -label NULL -labelmode NULL -enable -enabled\
          -userlabel NULL -flagadvertise NULL -flagtrafficdest NULL -flagflap NULL}

    array set original_parameter_list [GetAttributeList $m_BlockArray($args_array(-blockname))\
        [array get routeRange_parameter_list]]

    #set sg_routerange
    set routeRange_parameter_as {-as_sequence asSequence -as_set asSet -confeed_sequenced \
        asConfedSequence  -confeed_set asConfedSet}
        
    array set original_parameter_list2 [GetAttributeList $m_BlockArray($args_array(-blockname))/asSegment\
        [array get routeRange_parameter_as]]
    
    set t_list [array get routeRange_parameter_list]
    lappend t_list -as_sequence asSequence -as_set asSet -confeed_sequenced \
        asConfedSequence  -confeed_set asConfedSet -blockname a
    if {[CheckArgs $procname $t_list [array get args_array]] == 0} {
        return $::FAILURE 
    } 
    
    set t_result [concat [array get original_parameter_list] [array get original_parameter_as]] 
    
    #ȡ�����list, ����uplevel
    #--------------------------
    unset args_array(-blockname)
    foreach {key value} [array get args_array] {
        if {[info exists original_parameter_list($key)]} {
            uplevel 1 "set $value $original_parameter_list($key)"
        } else {
            uplevel 1 "set $value $original_parameter_as($key)"
        }
    } 
    return $::SUCCESS       
}

#====================================================================
# ��������:CreateMplsVpn by sigma 2009.3.6
# ����: ����MPLS VPN
# ����:
#      VpnName	Vpn������	��ѡ       ֧��
#      RTType		��ѡ                ֧��
#      RTImport		��ѡ                ֧��
#      RTExport		��ѡ                ֧��
#      RD		��ѡ                    ֧��
# �﷨����:
#    <obj> CreateMplsVpn
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::CreateMplsVpn {args} {
    ixDebugPuts "Enter proc BgpRouter::CreateMplsVpn...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }

    #�����Ҫ��ѡ�����Ƿ����
    #------------------------
    if {![info exists args_array(-vpnname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -VpnName."
        return $::FAILURE
    }
    
    if {![info exists args_array(-rttype)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -rttype."
        return $::FAILURE
    }
    
    if {![info exists args_array(-rtimport)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -rtimport."
        return $::FAILURE
    }
    
    if {![info exists args_array(-rd)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -rd."
        return $::FAILURE
    }
    
    set prarmeter_list {-vpnname vpnname -rttype rttype -rtimport rtimport -rd rd -rtexport rtexport}
    if {[CheckArgs $procname $prarmeter_list [array get args_array]] == 0} {
        return $::FAILURE 
    }     
    
    set rttype as
    if {$args_array(-rttype) == "IPv4"} {
        set rttype ip
    }
    set m_mpls_type $rttype
    
    #�����������
    #-----------------
    set import_value $args_array(-rtimport)
    set offset [string first ":" $import_value]
    incr offset -1
    set import_value1 [string range $import_value 0 $offset]
    incr offset +2
    set import_value2 [string range $import_value $offset end]
    set sg_l3Site [ixNet add $m_sg_neighborRange l3Site]
    ixNet setAttribute $sg_l3Site -enabled True 
    ixNet setAttribute $sg_l3Site -trafficGroupId ::ixNet::OBJ-null
    lappend tmp_array1 $rttype $import_value1 $import_value1 $import_value2
    lappend tmp_array2 $tmp_array1
    ixNet setAttribute $sg_l3Site/importTarget -importTargetList  $tmp_array2
    unset tmp_array1
    unset tmp_array2
    ixNet setAttribute $sg_l3Site/multicast -enableMulticast True 
    ixNet setAttribute $sg_l3Site/multicast -enableMulticastCluster True 
    ixNet setAttribute $sg_l3Site/multicast -groupAddress 239.1.1.1
    ixNet setAttribute $sg_l3Site/multicast/cluster  -val  {  }
    set import_value $args_array(-rd)
    set offset [string first ":" $import_value]
    incr offset -1
    set import_value1 [string range $import_value 0 $offset]
    incr offset +2
    set import_value2 [string range $import_value $offset end]

    ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -asNumber $import_value1 
    ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -assignedNumber $import_value2 
    ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -ipAddress $import_value1 
    ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -type $rttype
    if {[info exists args_array(-rtexport)]} {
        set import_value $args_array(-rtexport)
        set offset [string first ":" $import_value]
        incr offset -1
        set import_value1 [string range $import_value 0 $offset]
        incr offset +2
        set import_value2 [string range $import_value $offset end]
        lappend tmp_array1 $rttype $import_value1 $import_value1 $import_value2
        lappend tmp_array2 $tmp_array1
        ixNet setAttribute $sg_l3Site/target -targetList $tmp_array2
    }
    
    #commit and save the object in global value
    ixNet commit
    set sg_l3Site [lindex [ixNet remapIds $sg_l3Site] 0]
    array set tmp $m_mpls_name
    set tmp($args_array(-vpnname)) $sg_l3Site
    set m_mpls_name [array get tmp]
    return $::SUCCESS
}


#====================================================================
# ��������:ConfigMplsVpn by sigma 2009.3.6
# ����: ����MPLS VPN
# ����:
#      VpnName	Vpn������	��ѡ       ֧��
#      RTType		��ѡ                ֧��
#      RTImport		��ѡ                ֧��
#      RTExport		��ѡ                ֧��
#      RD		��ѡ                    ֧��
# �﷨����:
#    <obj> ConfigMplsVpn
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::ConfigMplsVpn {args} {
    ixDebugPuts "Enter proc BgpRouter::ConfigMplsVpn...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }

    if {![info exists args_array(-vpnname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -VpnName."
        return $::FAILURE
    }

    #���mpls vpn name�Ƿ����
    #----------------------
    array set mpls_name $m_mpls_name
    if {![info exists mpls_name($args_array(-vpnname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    
    set sg_l3Site $mpls_name($args_array(-vpnname))
    
    set rttype $m_mpls_type
    if {[info exists args_array(-rttype)]} {
        if {$args_array(-rttype) == "IPv4"} {
            set rttype ip
        }
    }
    
    set prarmeter_list {-vpnname vpnname -rttype rttype -rtimport rtimport -rd rd -rtexport rtexport}
    if {[CheckArgs $procname $prarmeter_list [array get args_array]] == 0} {
        return $::FAILURE 
    }     
    #����rtimport����
    #----------------
    if {[info exists args_array(-rtimport)]} {
        set import_value $args_array(-rtimport)
        set offset [string first ":" $import_value]
        incr offset -1
        set import_value1 [string range $import_value 0 $offset]
        incr offset +2
        set import_value2 [string range $import_value $offset end]
        lappend tmp_array1 $rttype $import_value1 $import_value1 $import_value2
        lappend tmp_array2 $tmp_array1
        ixNet setAttribute $sg_l3Site/importTarget  -importTargetList $tmp_array2
        unset tmp_array1
        unset tmp_array2
    }
   
    #����rtexport����
    #----------------
    if {[info exists args_array(-rtexport)]} {
        set import_value $args_array(-rtexport)
        set offset [string first ":" $import_value]
        incr offset -1
        set import_value1 [string range $import_value 0 $offset]
        incr offset +2
        set import_value2 [string range $import_value $offset end]
        lappend tmp_array1 $rttype $import_value1 $import_value1 $import_value2
        lappend tmp_array2 $tmp_array1
        ixNet setAttribute $sg_l3Site/target -targetList $tmp_array2
    }
    
    #����rd����
    #----------------
    if {[info exists args_array(-rd)]} {
        set import_value $args_array(-rd)
        set offset [string first ":" $import_value]
        incr offset -1
        set import_value1 [string range $import_value 0 $offset]
        incr offset +2
        set import_value2 [string range $import_value $offset end]
        ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -asNumber $import_value1 
        ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -assignedNumber $import_value2 \
        ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -ipAddress $import_value1 \
        ixNet setAttribute $sg_l3Site/multicast/routeDistinguisher -type $rttype
    }
    
    ixNet commit
    return $::SUCCESS    
}

#====================================================================
# ��������:DeleteMplsVpn by sigma 2009.3.6
# ����: ɾ��MPLS VPN
# ����:
#      VpnName	Vpn������	��ѡ        ֧��
# �﷨����:
#    <obj> DeleteMplsVpn
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::DeleteMplsVpn {args} {
    ixDebugPuts "Enter proc BgpRouter::DeleteMplsVpn...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }

    array set mpls_name $m_mpls_name
    if {![info exists mpls_name($args_array(-vpnname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
   
    set prarmeter_list {-vpnname vpnname}
    if {[CheckArgs $procname $prarmeter_list [array get args_array]] == 0} {
        return $::FAILURE 
    }     
    #ɾ����Ӧ��mpls vpn
    #--------------------
    ixNet remove $mpls_name($args_array(-vpnname))
    ixNet commit
    unset mpls_name($args_array(-vpnname))
    set m_mpls_name [array get mpls_name]
    return $::SUCCESS    
}

#====================================================================
# ��������:AddRouteBlockToVPN by sigma 2009.3.6
# ����: ΪVPN���·�ɿ�
# ����:
#     RouteBlockName	RouteBlock�����б��ո���	��ѡ   ֧��
#     VPNName		                                   ��ѡ   ֧��
#     LabelMode                                    ��ѡ   ��֧��
# �﷨����:
#    <obj> AddRouteBlockToVPN
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::AddRouteBlockToVPN {args} {
    ixDebugPuts "Enter proc BgpRouter::AddRouteBlockToVPN...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]


    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }

    if {![info exists args_array(-routeblockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    set prarmeter_list {-vpnname vpnname -routeblockname RouteBlockName}
    if {[CheckArgs $procname $prarmeter_list [array get args_array]] == 0} {
        return $::FAILURE 
    }     
    
    #���blockname�Ƿ����
    #----------------------
    array set routerblock_name $m_vpn_routerblock_name
    if {[info exists routerblock_name($args_array(-routeblockname))]} {
        set ::ERRINFO  "$procname: the name of router block already exist."
        return $::FAILURE
    }
    
    #���mpls vpn�Ƿ����
    #---------------------
    array set mpls_name $m_mpls_name
    if {![info exists mpls_name($args_array(-vpnname))]} {
        set ::ERRINFO  "$procname: the name of vpnname block not exist."
        return $::FAILURE
    }
    
    array set route_vpn_arrays $m_route_vpn_arrays
    if {![info exists route_vpn_arrays($args_array(-routeblockname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    
    #����route_vpn_arrays��Ĭ�ϲ���array
    #--------------------------------
    array set args_arrays $route_vpn_arrays($args_array(-routeblockname))
   
    
    array set vpn_routeRange_parameter_list {-aggregatorAsNum 0\
        -aggregatorIpAddress {0.0.0.0} -distinguisherAsNumber 0\
        -distinguisherAssignedNumber 0 -distinguisherCount 1\
        -distinguisherIpAddress {0.0.0.0} -distinguisherMode local\
        -distinguisherStep 1 -distinguisherType as -enableAggregator True\
        -enableAggregatorIdIncrementMode True -enableAsPath True\
        -enableAtomicAttribute True -enableCluster True -enableCommunity False\
        -enableGenerateUniqueRoutes True -enableLocalPref True\
        -enableMed False -enableNextHop True -enableOrigin True\
        -enableOriginatorId False -enableTraditionalNlriUpdate True\
        -enabled True -fromPacking 0 -fromPrefix 24 -ipType ipv4\
        -iterationStep 1 -localPref 0 -med 0 -networkAddress {0.0.0.0}\
        -nextHopIpAddress {0.0.0.0} -nextHopMode nextHopIncrement\
        -nextHopSetMode sameAsLocalIp -numRoutes 1 -originProtocol igp\
        -originatorId {0.0.0.0} -thruPacking 0 -thruPrefix 24}

    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set vpn_routeRange_args_list {-addressfamily -ipType \
        -firstroute -networkAddress -prefixlen -fromPrefix -routenum \
        -numRoutes -modifier -iterationStep -active -enabled -origin \
        -originProtocol -next_hop NULL -med -med -local_pref -localPref \
        -atomatic_aggregate NULL -aggregator_as NULL -aggrgator_ipaddress \
        -aggregatorIpAddress -originator_id -originatorId -cluster_list \
        NULL -communities -enableCommunity -flagadvertise NULL \
        -flagtrafficdest NULL}
    
    set sg_l3Site $mpls_name($args_array(-vpnname))
    set sg_vpnRouteRange [ixNet add $sg_l3Site vpnRouteRange]
    array set routerblock_name $m_vpn_routerblock_name
    set routerblock_name($args_arrays(-blockname)) [CommitIxNetParameter \
        $sg_vpnRouteRange [array get vpn_routeRange_parameter_list] \
        [array get vpn_routeRange_args_list] [array get args_arrays]]
    
    if {[info exists args_arrays(-nexthop)]} {
        set sg_routeRange $routerblock_name($args_arrays(-blockname))
        ixNet setAttribute $sg_routeRange -nextHopSetMode setManually 
        ixNet setAttribute $sg_routeRange -nextHopMode nextHopIncrement
        ixNet setAttribute $sg_routeRange -nextHopIpAddress $args_arrays(-nexthop)
        ixNet commit        
        set sg_routeRange [lindex [ixNet remapIds $sg_routeRange] 0]
    }
    #����as sequence
    #-----------------
    set routeRange_parameter_as {-as_sequence asSequence -as_set asSet 
        -confeed_sequenced asConfedSequence  -confeed_set asConfedSet}
    set list_as {}

    foreach {para_key ixNet_key} [array get routeRange_parameter_as] {
        if {[info exists args_arrays($para_key)]} {
            lappend tmp True $ixNet_key $args_arrays($para_key)
            lappend list_as $tmp
            unset tmp
        }
    }
    ixNet setAttribute $routerblock_name($args_arrays(-blockname))/asSegment \
        -asSegments $list_as
    ixNet commit
    set routerblock_name($args_arrays(-blockname)) [lindex [ixNet remapIds $routerblock_name($args_arrays(-blockname))] 0]
    
    #���浽ȫ�ֱ���
    #--------------------
    set m_vpn_routerblock_name [array get routerblock_name]
    return $::SUCCESS
}

itcl::body BgpRouter::DeleteVpnRouteBlock_p {args} {
    set args [lindex $args 0]
    return [DeleteRouteBlock [lindex $args 0] [lindex $args 1]]
}

#====================================================================
# ��������:RemoveRouteBlockFromVPN by sigma 2009.3.6
# ����: ΪVPNɾ��·�ɿ�
# ����:
#     RouteBlockName	RouteBlock�����б��ո���	��ѡ   ֧��
#     VPNName		��ѡ    ֧��
# �﷨����:
#    <obj> RemoveRouteBlockFromVPN
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::RemoveRouteBlockFromVPN {args} {
    ixDebugPuts "Enter proc BgpRouter::RemoveRouteBlockFromVPN...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    set prarmeter_list {-vpnname vpnname -routeblockname RouteBlockName}
    if {[CheckArgs $procname $prarmeter_list [array get args_array]] == 0} {
        return $::FAILURE 
    }     
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-routeblockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    #��ȡ route name list
    #-------------------
    array set routerblock_name $m_vpn_routerblock_name
    set list_block_name $args_array(-routeblockname) 
    foreach {vpn_route_name} $list_block_name {
        if {![info exists routerblock_name($vpn_route_name)]} {
           set ::ERRINFO  "$procname: the name of router block not exist."
           return $::FAILURE
        }
        DeleteVpnRouteBlock -routeblockname $vpn_route_name
    }
    
    return $::SUCCESS
}


itcl::body BgpRouter::ConfigVpnRouteBlock_p {args} {
    set procname [lindex [info level [info level]] 0]
    set args [lindex $args 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    #���blockname�Ƿ����
    #----------------------    
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    array set routerblock_name $m_vpn_routerblock_name
    if {![info exists routerblock_name(args_array(-blockname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    set sg_routeRange $routerblock_name($args_array(-blockname))
    
    #���øú����������key��Ĭ�ϲ���key�Ķ�Ӧ��ϵ
    #--------------------------------------------
    array set vpn_routeRange_args_list {-addressfamily -ipType \
        -firstroute -networkAddress -prefixlen -fromPrefix -routenum \
        -numRoutes -modifier -iterationStep -active -enabled -origin \
        -originProtocol -med -med -local_pref -localPref \
        -atomatic_aggregate NULL -aggregator_as NULL -aggrgator_ipaddress \
        -aggregatorIpAddress -originator_id -originatorId -cluster_list \
        NULL -communities -enableCommunity -flagadvertise NULL \
        -flagtrafficdest NULL}
    
    array set original_parameter_list [GetIxiaList $sg_routeRange \
        [array get routeRange_parameter_list]]
    
    set routerblock_name($args_array(-blockname)) [CommitIxNetParameter \
        $sg_routeRange [array get original_parameter_list] \
        [array get vpn_routeRange_args_list] [array get args_array] no]
        
    if {[info exists args_arrays(-nexthop)]} {
        set sg_routeRange $routerblock_name($args_arrays(-blockname))
        ixNet setAttribute $sg_routeRange -nextHopSetMode setManually 
        ixNet setAttribute $sg_routeRange -nextHopMode nextHopIncrement
        ixNet setAttribute $sg_routeRange -nextHopIpAddress $args_arrays(-nexthop)
        ixNet commit        
        set routerblock_name($args_array(-blockname)) [lindex [ixNet remapIds $sg_routeRange] 0]
    }
    
    set sg_routeRange $routerblock_name($args_array(-blockname)) 

    #����as sequence
    #-----------------
    array set routeRange_parameter_as {-as_sequence asSequence -as_set asSet \
        -confeed_sequenced asConfedSequence  -confeed_set asConfedSet}

    set list_as {}
    foreach {para_key ixNet_key} [array get routeRange_parameter_as] {
        if {[info exists args_array($para_key)]} { 
            set as_list [ixNet getList $sg_routeRange asSegment]
            foreach t $as_list {
                ixNet remove $t
            }
        }
    }

    foreach {para_key ixNet_key} [array get routeRange_parameter_as] {
        if {[info exists args_array($para_key)]} {
            lappend tmp True $ixNet_key $args_array($para_key)
            lappend list_as $tmp
            unset tmp
        }
    }
    
    ixNet setAttribute $sg_routeRange\/asSegment -asSegments $list_as
    ixNet commit
    return $::SUCCESS
}

#====================================================================
# ��������:CreateVpnRouteBlock by sigma 2009.3.6
# ����: ��Bgp Router��·�ɿ�
# ����:
#    BlockName	RouteBlock����	��ѡ                     ֧��               
#    AddressFamily	IPv4 or IPv6	��ѡ                   ֧��               
#    FirstRoute	RouteBlock����ʼ��ַ	��ѡ                ֧��               
#    PrefixLen	RouteBlock��ǰ׺����	��ѡ                ֧��               
#    RouteNum	RouteBlock����Ŀ����	��ѡ                  ֧��               
#    Modifier	RouteBlock�ı仯����	��ѡ                  ֧��               
#    Active	�򿪻�ر�·�ɳ� enable/disable	             ֧��               
#    AS_SEQUENCE	 ��˳���ɵ�AS �ż���	��ѡ            ֧��               
#    AS-SET	 δ��˳���ɵ� AS�ż���	��ѡ               ֧��              
#    CONFEED_SEQUENCED	 ���˵�AS�� 	��ѡ               ֧��               
#    CONFEED_SET	 	��ѡ                                  ֧��               
#    ORIGIN	���ϱ�ѡ���ԣ�IGPΪ0��BGPΪ1	��ѡ            ֧��               
#    NEXT HOP	������Ŀ�ĵ�ַ��·����һ��	��ѡ             ֧��              
#    MED	Ӱ������AS��ҵ��ԽСԽ����	��ѡ               ֧��              
#    LOCAL_PREF	�����ڱ���AS�ڣ�ֵԽ��Խ����	��ѡ         ֧��              
#    ATOMATIC_AGGREGATE	ԭ�Ӿۺ� ������Ǻ�������	��ѡ         ��֧��       
#    AGGREGATOR_AS		��ѡ                                 ֧��             
#    AGGRGATOR_IPADDRESS		��ѡ                           ֧��             
#    ORIGINATOR_ID	RRʹ�õģ���·�ɷ����߲�����һ��32���ص�ֵ��	��ѡ   ֧��
#    CLUSTER_LIST	RRʹ�õģ�·�ɾ�����������ID��һ����š�	��ѡ    ��֧��
#    COMMUNITIES	��������	��ѡ                                  ֧��  
#    FlagAdvertise		                ��֧��
#    FlagTrafficDest		            ��֧��
#    FlagFlap		
# �﷨����:
#    <obj> CreateVpnRouteBlock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::CreateVpnRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::CreateVpnRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    array set route_vpn_arrays $m_route_vpn_arrays
    if {[info exists routerblock_name($args_array(-blockname))]} {
        set ::ERRINFO  "$procname: the name of router block already exist."
        return $::FAILURE
    }
    
    set vpn_routeRange_args_list {-addressfamily -ipType \
        -firstroute -networkAddress -prefixlen -fromPrefix -routenum \
        -numRoutes -modifier -iterationStep -active -enabled -origin \
        -originProtocol -next_hop NULL -med -med -local_pref -localPref \
        -atomatic_aggregate NULL -aggregator_as NULL -aggrgator_ipaddress \
        -aggregatorIpAddress -originator_id -originatorId -cluster_list \
        NULL -communities -enableCommunity -flagadvertise NULL \
        -flagtrafficdest NULL -nexthop nexthop -as_sequence asSequence -as_set asSet \
        -confeed_sequenced asConfedSequence  -confeed_set asConfedSet -blockname blockname}
    
    if {[CheckArgs $procname $vpn_routeRange_args_list [array get args_array]] == 0} {
        return $::FAILURE 
    }   
    
    set route_vpn_arrays($args_array(-blockname)) $args
    set m_route_vpn_arrays [array get route_vpn_arrays]
    return $::SUCCESS
}

#====================================================================
# ��������:DeleteVpnRouteBlock by sigma 2009.3.6
# ����: ����Bgp Router��·�ɿ�
# ����:
#    BlockName	    RouteBlock����	��ѡ    ֧��
# �﷨����:
#    <obj> DeleteRouteBlock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::DeleteVpnRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::DeleteVpnRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-routeblockname)]} {
        
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        puts $::ERRINFO
        return $::FAILURE
    }

    set prarmeter_list {-routeblockname blockname}
    if {[CheckArgs $procname $prarmeter_list [array get args_array]] == 0} {
        return $::FAILURE 
    }     
    
    array set route_vpn_arrays $m_route_vpn_arrays
    if {![info exists route_vpn_arrays($args_array(-routeblockname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        puts $::ERRINFO
        return $::FAILURE
    } else {
        set deleteid [expr [lsearch $m_vpn_routerblock_name $args_array(-routeblockname)] + 1]
        set sg_routeRange [lindex $m_vpn_routerblock_name $deleteid]
        ixNet remove $sg_routeRange
        set m_vpn_routerblock_name [lreplace $m_vpn_routerblock_name [expr $deleteid -1] $deleteid]
        ixNet commit
    }
    
    unset route_vpn_arrays($args_array(-routeblockname))
    set m_route_vpn_arrays [array get route_vpn_arrays]
    return $::SUCCESS
}

#====================================================================
# ��������:ConfigVpnRouteBlock by sigma 2009.3.6
# ����: ����Bgp Router��·�ɿ�
# ����:
#    BlockName	RouteBlock����	��ѡ                     ֧��               
#    AddressFamily	IPv4 or IPv6	��ѡ                 ֧��               
#    FirstRoute	RouteBlock����ʼ��ַ	��ѡ             ֧��               
#    PrefixLen	RouteBlock��ǰ׺����	��ѡ             ֧��               
#    RouteNum	RouteBlock����Ŀ����	��ѡ             ֧��               
#    Modifier	RouteBlock�ı仯����	��ѡ             ֧��               
#    Active	�򿪻�ر�·�ɳ� enable/disable	             ֧��               
#    AS_SEQUENCE	 ��˳���ɵ�AS �ż���	��ѡ         ֧��               
#    AS-SET	 δ��˳���ɵ� AS�ż���	��ѡ              ֧��              
#    CONFEED_SEQUENCED	 ���˵�AS�� 	��ѡ             ֧��               
#    CONFEED_SET	 	��ѡ                             ֧��               
#    ORIGIN	���ϱ�ѡ���ԣ�IGPΪ0��BGPΪ1	��ѡ         ֧��               
#    NEXT HOP	������Ŀ�ĵ�ַ��·����һ��	��ѡ          ֧��              
#    MED	Ӱ������AS��ҵ��ԽСԽ����	��ѡ          ֧��              
#    LOCAL_PREF	�����ڱ���AS�ڣ�ֵԽ��Խ����	��ѡ      ֧��              
#    ATOMATIC_AGGREGATE	ԭ�Ӿۺ� ������Ǻ�������	��ѡ         ��֧��       
#    AGGREGATOR_AS		��ѡ                               ֧��             
#    AGGRGATOR_IPADDRESS		��ѡ                       ֧��             
#    ORIGINATOR_ID	RRʹ�õģ���·�ɷ����߲�����һ��32���ص�ֵ��	��ѡ   ֧��
#    CLUSTER_LIST	RRʹ�õģ�·�ɾ�����������ID��һ����š�	��ѡ    ��֧��
#    COMMUNITIES	��������	��ѡ                                  ֧��  
#    FlagAdvertise		                ��֧��
#    FlagTrafficDest		            ��֧��
#    FlagFlap		
# �﷨����:
#    <obj> ConfigVpnRouteBlock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::ConfigVpnRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::ConfigVpnRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {![info exists args_array(-blockname)]} {
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    
    array set route_vpn_arrays $m_route_vpn_arrays
    if {![info exists route_vpn_arrays($args_array(-blockname))]} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    
    set vpn_routeRange_args_list {-addressfamily -ipType \
        -firstroute -networkAddress -prefixlen -fromPrefix -routenum \
        -numRoutes -modifier -iterationStep -active -enabled -origin \
        -originProtocol -med -med -local_pref -localPref \
        -atomatic_aggregate NULL -aggregator_as NULL -aggrgator_ipaddress \
        -aggregatorIpAddress -originator_id -originatorId -cluster_list \
        NULL -communities -enableCommunity -flagadvertise NULL \
        -flagtrafficdest NULL -nexthop nexthop -as_sequence asSequence -as_set asSet \
        -confeed_sequenced asConfedSequence  -confeed_set asConfedSet -blockname -name}
        
    if {[CheckArgs $procname $vpn_routeRange_args_list [array get args_array]] == 0} {
        return $::FAILURE 
    }   
        
    array set tmp_array $route_vpn_arrays($args_array(-blockname))

    #�滻ÿ��key
    #------------
    foreach {key values} $args {
        set tmp_array($key) $values
    }
    set route_vpn_arrays($args_array(-blockname)) [array get tmp_array]
    set m_route_vpn_arrays [array get route_vpn_arrays]
    ConfigVpnRouteBlock_p $args
    return $::SUCCESS
}

#====================================================================
# ��������:AdvertiseRouteBlock by sigma 2009.3.6
# ����: ͨ��BgpBlock ·��
# ����:
#    BlockName	    RouteBlock����	��ѡ        ֧��
# �﷨����:
#    <obj>  AdvertiseRouteBlock  -BlockName myblock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::AdvertiseRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::AdvertiseRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
 
    if {[CheckArgs $procname {-blockname name} [array get args_array]] == 0} {
        return $::FAILURE 
    }
    
    if {[array names m_BlockArray $args_array(-blockname)] == ""} {
        set ::ERRINFO  "the name of router block not exist."        
        return $::FAILURE
    }

    ixNet setAttribute $m_BlockArray($args_array(-blockname)) -enabled True
    ixNet commit
    return $::SUCCESS
}

#====================================================================
# ��������:WithdrawRouteBlock by sigma 2009.3.6
# ����: ����BgpBlock ·��
# ����:
#    BlockName	    RouteBlock����	��ѡ    ֧��
# �﷨����:
#    <obj>  WithdrawRouteBlock  -BlockName myblock
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::WithdrawRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::WithdrawRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    if {[CheckArgs $procname {-blockname name} [array get args_array]] == 0} {
        return $::FAILURE 
    }
    
    if {[array names m_BlockArray $args_array(-blockname)] ==""} {
        set ::ERRINFO  "$procname: the name of router block not exist."
        return $::FAILURE
    }
    
    ixNet setAttribute $m_BlockArray($args_array(-blockname)) -enabled false
    ixNet commit
    return $::SUCCESS    
}

#====================================================================
# ��������:StartFlapRouteBlock by sigma 2009.3.6
# ����: Bgp·����
# ����:
#    BlockName	    RouteBlock����	��ѡ    ֧��
#    flapnumber  ����                       ֧��
# �﷨����:
#    BgpRouter StartFlapRouteBlock -BlockName mybloc
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::StartFlapRouteBlock {args} {    
    ixDebugPuts "Enter proc BgpRouter::StartFlapRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {[CheckArgs $procname {-blockname name -flapnumber 1} [array get args_array]] == 0} {
        return $::FAILURE 
    }
    
    #���blockname�Ƿ����, ���ҽ���Ҫ�𵴵�block ������ʱlist
    #--------------------------------------------------------
    set i 0
    set blockname_list {}
    if {![info exists args_array(-blockname)]} {
        foreach {$name $hand} $m_routerblock_name {
            lappend blockname_list $name
        }
    } else {
        lappend blockname_list $args_array(-blockname)
    }
    
    if {![info exists args_array(-flapnumber)]} {
        puts "$procname: Miss mandatory arg -flapnumber."
        set ::ERRINFO  "$procname: Miss mandatory arg -blockname."
        return $::FAILURE
    }
    set num $args_array(-flapnumber)
    
    #��ʼѭ����
    #-------------
    while {$i < $num} {
        set l 0
        for {set l 0} {$l < [llength $blockname_list]} {incr l} {
            AdvertiseRouteBlock -blockname [lindex $blockname_list $l]
            after $m_AWDTimer
            WithdrawRouteBlock  -blockname [lindex $blockname_list $l]
            after $m_WADTimer
        }
        incr i
    }
    return $::SUCCESS
}

#====================================================================
# ��������:StopFlapRouteBlock by sigma 2009.3.6
# ����: ֹͣBgp·�ɵ���
# ����:
#    BlockName	    RouteBlock����	��ѡ    ֧��
# �﷨����:
#    BgpRouter StopFlapRouteBlock -BlockName mybloc
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::StopFlapRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::StopFlapRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]

    #�жϵ�ǰ��������Ƿ����Ҫ��
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {[CheckArgs $procname {-blockname name} [array get args_array]] == 0} {
        return $::FAILURE 
    }

    #���blockname�Ƿ����, ���ҽ���Ҫֹͣ�𵴵�block ������ʱlist
    #--------------------------------------------------------    
    set i 0
    set blockname_list {}
    if {![info exists args_array(-blockname)]} {
        foreach {$name $hand} $m_routerblock_name {
            lappend blockname_list $name
        }
    } else {
        lappend blockname_list $args_array(-blockname)
    }
    
    foreach {values} $blockname_list {
        WithdrawRouteBlock -blockname $values
    }
    return $::SUCCESS
}

#====================================================================
# ��������:ConfigFlapRouteBlock by sigma 2009.3.6
# ����: ����Bgp·���𵴵ļ��ʱ��
# ����:
#    BlockName	    RouteBlock����	��ѡ        ֧��
#   AWDTimer	Advertise to Withdraw Delay  ms ֧��
#   WADTimer	Withdraw toAdvertise Delay   ms ֧��
# �﷨����:
#    BgpRouter ConfigFlapRouteBlock -AWDTimer 2000 -WADTimer 2000
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::ConfigFlapRouteBlock {args} {
    ixDebugPuts "Enter proc BgpRouter::ConfigFlapRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args [ixConvertToLowerCase $args]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    
    if {[CheckArgs $procname {-awdtimer awdtimer -wadtimer wadtimer} [array get args_array]] == 0} {
        return $::FAILURE 
    }
    
    #���ü��ʱ��
    #-------------
    if {[info exists args_array(-awdtimer)] && \
        [string is integer $args_array(-awdtimer)]} {
        set m_AWDTimer $args_array(-awdtimer)
    } else {
        puts "pls input valid awdtimer"
        return $::FAILURE
    }
    
    if {[info exists args_array(-wadtimer)] && \
        [string is integer $args_array(-wadtimer)]} {
        set m_WADTimer $args_array(-wadtimer)
    } else {
        puts "pls input valid wadtimer"
        return $::FAILURE
    }
    return $::SUCCESS    
}

#====================================================================
# ��������:GetRouterStats by sigma 2009.3.6
# ����: ֹͣBgp·�ɵ���
# ����:
#     BgpDuration	���Router����ʱ��	��ѡ  ��֧��
#     NumRouteRefreshRecevied		��ѡ        ֧��
#     NumRouteRefreshSent		��ѡ            ֧��
#     NumOpenReceived		��ѡ                ֧��
#     NumOpenSent		��ѡ                    ֧��
#     NumKeepAlivesReceived		��ѡ            ֧��
#     NumKeepAlivesSent		��ѡ                ֧��
#     NumUpdateReceived		��ѡ                ֧��
#     NumUpdeateSent		��ѡ                ֧��
#     NumNotificationReceived		��ѡ        ֧��
#     NumNotificationSent		��ѡ            ֧��
#     NumWithdrawRouteReceived		��ѡ        ֧��
#     NumWtihdrawRoutSent		��ѡ            ֧��
#     NumNlriReceived		��ѡ                ��֧��
#     NumNlriSend		��ѡ                    ��֧��
#     NumTcpWindowClosed		��ѡ            ��֧��
#     DurationTcpWindowClosed		��ѡ        ��֧��
# �﷨����:
#    BgpRouter StopFlapRouteBlock -BlockName mybloc
# ����ֵ��                                                          
#    FAILED or SUCCESSED                   
#====================================================================
itcl::body BgpRouter::GetRouterStats {args} {
    ixDebugPuts "Enter proc BgpRouter::GetRouterStats...\n"
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
    if {$state != "true" } {
        puts "Get ProtoStats stats failed!"
        return 1
    }
    ixNet setAttr $ProtoStats -currentPageNumber 0
    ixNet commit

    set Curpage [ixNet getAttr $ProtoStats -currentPageNumber]
    set row [lindex [ixNet getList $ProtoStats row] 0]

    while { $tmpllength > 0  } {
        set cmdx [lindex $args $idxxx]
        set value [lindex $args [expr $idxxx + 1]]
        case $cmdx      {
             -numrouterefreshrecevied {
                set MyObj [lindex [ixNet getList $row cell] 24]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig                
             }
             -numrouterefreshsent        {
                set MyObj [lindex [ixNet getList $row cell] 22]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig 
             }
             -numopenreceived      {
                set MyObj [lindex [ixNet getList $row cell] 17]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig 
             }
             -numopensent {
                set MyObj [lindex [ixNet getList $row cell] 16]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             } 
             -numkeepalivesreceived {
                set MyObj [lindex [ixNet getList $row cell] 19]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numkeepalivessent {
                set MyObj [lindex [ixNet getList $row cell] 18]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numupdatereceived {
                set MyObj [lindex [ixNet getList $row cell] 13]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numupdeatesent {
                set MyObj [lindex [ixNet getList $row cell] 12]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numnotificationreceived {
                set MyObj [lindex [ixNet getList $row cell] 21]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numnotificationsent {
                set MyObj [lindex [ixNet getList $row cell] 20]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numwithdrawroutereceived {
                set MyObj [lindex [ixNet getList $row cell] 9]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -numwtihdrawroutsent {
                set MyObj [lindex [ixNet getList $row cell] 8]  
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
# ��������: StartISISRouter
# ������д: ��׿ 2009.4.8
# ��������: ��ʼָ����Router��·�ɷ���
#           
# �������: ��  
#
# �﷨����:                                                         
#      IsisRouter StartISISRouter
#====================================================================

itcl::body BgpRouter::StartBGPRouter {} {
    ixDebugPuts "Enter proc BgpRouter::StartBGPRouter...\n"
    ##ixNet exec start $m_isisRouter
    #after 5000
    #ixNet exec startAllProtocols
    #puts "Router(s) are starting, check status in DUT, then press enter to continue!"
    #gets stdin k
    #puts "Started...."
    
    #ser r [ixNet getRoot]
    #set vPortList [ixNet getList $r vport]
    after 5000
    ixTclNet::StartProtocols "bgp"  $m_vportId
    
    
}

itcl::body BgpRouter::StopBGPRouter {} {
    ixDebugPuts "Enter proc BgpRouter::StopBGPRouter...\n"
    ixTclNet::StopProtocols "bgp"  $m_vportId
}

}


