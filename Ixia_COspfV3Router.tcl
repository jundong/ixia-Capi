#====================================================================
# 版本号：1.0
#
# 文件名：Ixia_COspfV3Router.tcl
#
# 文件描述：IxiaCapi库中OSPF路由类
#
# 作者：Sigma
#
# 创建时间: 2009.04.13
#
# 修改记录：
#
# 版权所有：Ixia
#====================================================================

#====================================================================
# 类名称:
#    ::OspfV3Router    by Sigma
# 描述:
#    该类为虚类，抽象所有具体端口的共同特征
#    父类：无
#    子类：具体的端口类，比如以太网端口类、低速链路端口类等
#    相关类：协议仿真类、流量发送引擎类和统计分析引擎类
# 语法描述:
#    TestDevice ipaddress
#    如：TestDevice Tester1 192.168.0.100
#====================================================================
namespace eval IxiaCapi {

itcl::class OspfV3Router {
    namespace import ::IxiaCapi::*

    public variable m_portObjectId    ""
    public variable m_chassisId       ""
    public variable m_slotId          ""
    public variable m_portId          ""
    public variable m_routerType      ""
    public variable m_routerId        ""
    public variable m_this            ""
    public variable m_namespace       ""
    public variable m_intfId          ""
    public variable m_intfIpv6Id      ""
    public variable m_intfMac         "00 00 00 00 00 01"
    public variable m_intfv6Ip        "2001:0:0:0:0:0:0:2"
    public variable m_intfv6Gateway   "2001:0:0:0:0:0:0:1"
    public variable m_intfv6IpMask    "64"
    public variable m_RouterId_List ""
    public variable m_GridName_List ""
    #public variable m_userLsaRouterID_List ""
    public variable m_userLsaRouterName_List ""
    public variable m_userTopRouter_List ""
    public variable m_userLsaGroup_Seq 0
    public variable m_userLsaGroup_List ""
    public variable m_TopRouterLink_InterAttr_List ""
    public variable m_TopRouterLink_InterID_List ""
    public variable m_TopInterAreaPrefixRouteBlock ""
    #public variable m_sg_ipv6_no ""
    #public variable m_interface_id 0
    #public variable m_routerblocak_name() ""
    #public variable m_RouterName {}
    #public variable m_RouterLsaName {}

    inherit Router
    constructor {portobj routertype {routerid 192.168.1.1}} \
    {Router::constructor $portobj $routertype $routerid} {
        set m_portObjectId $portobj
        set m_chassisId [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_chassisId]
        set m_slotId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_slotId]
        set m_portId    [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_portId]
        set m_routerType $routertype
        set m_routerId  $routerid
        set m_this      [namespace tail $this]
        set m_namespace [namespace qualifiers $this]
        set IxiaCapi::namespaceArray($m_this,namespace) $m_namespace

        set vport [$IxiaCapi::namespaceArray($portobj,namespace)::$portobj cget -m_vportId]
        set m_intfId [ixNet add $vport interface]
        ixNet setAttribute $m_intfId -enabled true
        ixNet setAttribute $m_intfId -description "$m_this"
        #ixNet setAttribute $m_intfId/ethernet -macAddress $m_intfMac
        ixNet commit
        set m_intfId [lindex [ixNet remapIds $m_intfId] 0]
        #set m_interface_id [expr ([llength [ixNet getList $vport interface]] - 1)]

        set m_intfIpv6Id [ixNet add $m_intfId ipv6]
        #ixNet setAttribute $m_intfIpv6Id -ip            $m_intfv6Ip
        #ixNet setAttribute $m_intfIpv6Id -gateway       $m_intfv6Gateway
        #ixNet setAttribute $m_intfIpv6Id -prefixLength  $m_intfv6IpMask
        ixNet commit
        set m_intfIpv6Id [lindex [ixNet remapIds $m_intfIpv6Id] 0]

        #set m_sg_ipv6_no [expr ([llength [ixNet getList $m_intfId ipv6]] - 1)]
        #set m_intfIpv6Id [lindex [ixNet remapIds $m_intfIpv6Id] 0]

        #ixNet setAttribute $vport/protocols/ping -enabled True
        ixNet setAttribute $vport/protocols/ospfV3 -enabled True
        ixNet setAttribute $vport/protocols/arp -enabled True
        ixNet commit
        set vport [lindex [ixNet remapIds $vport] 0]
}

    destructor {
    }
    
    public method GetAttributeList
    public method ConfigRouter
    public method GetRouter
    public method Enable
    public method Disable
    public method AddTopGrid
    public method GetTopGrid
    public method RemoveTopGrid
    private method CreateUserLsa
    public method AddTopRouter
    public method GetTopRouter
    public method RemoveTopRouter
    public method AddTopRouterLink
    public method RemoveTopRouterLink
    public method AddTopNetwork
    public method RemoveTopNetwork
    public method CreateTopExternalPrefixRouteBlock
    public method ConfigTopExternalPrefixRouteBlock
    public method GetTopExternalPrefixRouteBlock
    public method DeleteTopExternalPrefixRouteBlock
    public method CreateTopInterAreaPrefixRouteBlock
    public method ConfigTopInterAreaPrefixRouteBlock
    public method GetTopInterAreaPrefixlRouteBlock
    public method DeleteTopInterAreaPrefixRouteBlock
    public method GetRouterStats
}

#====================================================================
# 函数名称:GetAttributeList by sigma 2009.3.6                                                  
# 描述: 根据传进来的Ixia对象的句柄, 配置Ixia的各个模块. 
# 参数:
# list 1: Ixia对象的句柄
# list 2: 需要获取的参数组成的list
# 语法描述:                                                         
#    GetAttributeList $sg_neighborRange [array get neighborRange_parameter_list]
# 返回值：                                                          
#    返回对应的array                        
#====================================================================
itcl::body OspfV3Router::GetAttributeList {args} {
    set procname [lindex [info level [info level]] 0]
    set ActionType [lindex $args 0]
    set args [lindex $args 1];
    
    #判断当前输入参数是否符合要求
    #----------------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }    
    
    #通过getAttribute加入所有参数到ixia
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
# 函数名称:ConfigRouter by sigma 2009.4.15
# 描述: 配置OSPF Router 的所有可选配置属性
# 参数:
# IpAddr:               仿真的ospf router接口地址
# PrefixLen:            仿真的ospf router地址前缀，格式点分十进制表示
# Area:                 仿真ospf router 所在的区域号
# NetworkType:          网络类型，broadcast/NBMA/P2P
# RouterID:             Tester自身的router id
# OptionValue:          Capability of the ospf router. N-bit E-bit O-bit v6-Bit R-Bit Dc-Bit
# SutIpAddress:         连接的sut地址
# SutPrefixLen:         连接的sut掩码长度  eg：24
# SutRouterID:
# FlagNeighborDr:
# HelloInterval:        Ospf hello 报文时间间隔,单位：s
# DeadInterval:         Ospf Dead Interval，单位：s
# PollInterval:         Ospf Polling hello Interval,单位：s
# RetransmitInterval:   Ospf Retransmit Interval，单位：s
# TransitDelay:         LSA Transit Delay，单位：s
# MaxLSAsPerPacket:     LSU中包含的最大LSA数
# InterfaceCost:
# RouterPriority:
# MTU:                  Mtu
# LSADiscardMode:
# InstanceID:
# InternalMessageExchanger
# Active                是否启用该仿真ospf router,值为true or false
# 语法描述:
#   ospf1 ConfigRouter -Ipaddr 1.1.1.1 -area 0
#   RouterOspf  ConfigRouter -TransitDelay 3
# 返回值：
#    成功0，失败1
#====================================================================

itcl::body OspfV3Router::ConfigRouter {args} {
    ixDebugPuts "Enter proc OspfV3Router::ConfigRouter...\n"
    set args [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]

    #判断参数是否存在并赋值
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    #判断必选参数IpAddr是否被赋值
    if {![info exists args_array(-ipaddr)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -IpAddr."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set IpAddr $args_array(-ipaddr)
    }

    #Default Value Setting
    set PrefixLen "64"
    set Area 0
    set NetworkType "broadcast"
    set RouterID "30.128.0.0"
    set OptionValue 19
    set SutIpAddress "2001:0:0:0:0:0:0:1" ;#No Found
    set SutPrefixLen 64 ;#No Found
    set SutRouterID "" ;#Mo Found
    set FlagNeighborDr "" ;#No Found
    set HelloInterval 10
    set DeadInterval 40
    set PollInterval "" ;#No Found
    set RetransmitInterval "" ;#No Found
    set TransitDelay 5
    set MaxLSAsPerPacket 1000
    set InterfaceCost "" ;#No Found
    set RouterPriority "" ;#No Found
    set MTU 1500
    set LSADiscardMode "True"
    set InstanceID 0
    set InternalMessageExchanger 0
    set Active "True"

    if {[info exists args_array(-prefixlen)]} {
        set PrefixLen $args_array(-prefixlen)
    }

    if {[info exists args_array(-area)] && [string is integer $args_array(-area)]} {
        set Area $args_array(-area)
    }

    if {[info exists args_array(-networktype)]} {
        set NetworkType $args_array(-networktype)
    }

    if {[info exists args_array(-routerid)]} {
        set RouterID $args_array(-routerid)
    }

    if {[info exists args_array(-optionvalue)]} {
        set OptionValue $args_array(-optionvalue)
    }

    if {[info exists args_array(-sutipaddress)]} {
        set SutIpAddress $args_array(-sutipaddress)
    }

    if {[info exists args_array(-sutprefixlen)]} {
        set SutPrefixLen $args_array(-sutprefixlen)
    }

    if {[info exists args_array(-hellointerval)]} {
        set HelloInterval $args_array(-hellointerval)
    }

    if {[info exists args_array(-deadinterval)]} {
        set DeadInterval $args_array(-deadinterval)
    }

    if {[info exists args_array(-transitdelay)]} {
        set TransitDelay $args_array(-transitdelay)
    }

    if {[info exists args_array(-maxlsasperpacket)]} {
        set MaxLSAsPerPacket $args_array(-maxlsasperpacket)
    }

    if {[info exists args_array(-mtu)]} {
        set MTU $args_array(-mtu)
    }

    if {[info exists args_array(-lsadiscardmode)]} {
        set LSADiscardMode $args_array(-lsadiscardmode)
    }

    if {[info exists args_array(-instanceid)]} {
        set InstanceID $args_array(-instanceid)
    }

    if {[info exists args_array(-internalmessageexchanger)]} {
        set InternalMessageExchanger $args_array(-internalmessageexchanger)
    }

    if {[info exists args_array(-active)]} {
        if {[string is false $args_array(-active)] || [string is true $args_array(-active)]} {
            set Active $args_array(-active)
        }
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]

    ixNet setAttribute $m_intfId -description "$IpAddr/$PrefixLen"
    ixNet commit
    set m_intfId [lindex [ixNet remapIds $m_intfId] 0]

    ixNet setMultiAttrs $m_intfIpv6Id -ip $IpAddr \
        -prefixLength $PrefixLen
    ixNet commit
    set m_intfIpv6Id [lindex [ixNet remapIds $m_intfIpv6Id] 0]

    set sg_router [ixNet add $vport/protocols/ospfV3 router]
    ixNet setMultiAttrs $sg_router -discardLearnedLsa $LSADiscardMode \
        -enabled $Active \
        -maxNumLsaPerSecond $MaxLSAsPerPacket \
        -routerId $RouterID
    ixNet commit
    set m_sg_router [lindex [ixNet remapIds $sg_router] 0]

    set sg_interface [ixNet add $m_sg_router interface]
    ixNet setMultiAttrs $sg_interface \
        -area $Area \
        -deadInterval $DeadInterval \
        -enabled True \
        -helloInterval $HelloInterval \
        -instanceId $InstanceID \
        -interfaceType $NetworkType \
        -protocolInterface $m_intfId \
        -routerOptions $OptionValue
    ixNet commit
    set m_sg_interface [lindex [ixNet remapIds $sg_interface] 0]

    ixDebugPuts "End of proc OspfV3Router::ConfigRouter...\n"
    return $::SUCCESS
}

#==============================================
# 函数名称:GetRouter by sigma 2009.4.16
# 描述: 获取ospfRotuer的属性信息
# 参数:
# 语法描述:
#    ospf1 GetRouter -TransitDelay
# 返回值：
#    返回对应的array
#==============================================

itcl::body OspfV3Router::GetRouter {args} {
    ixDebugPuts "Enter proc OspfV3Router::GetRouter...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set v_sg_interface [lindex [ixNet getList $vport interface] 0]
    set sg_ipv6 [lindex [ixNet getList $v_sg_interface ipv6] 0]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_interface [lindex [ixNet getList $sg_router interface] 0]

    array set router_attr_list {-lsadiscardmode -discardLearnedLsa -active -enabled \
        -maxlsasperpacket -maxNumLsaPerSecond -routerid -routerId}
    array set interface_attr_list {-area -area -deadinterval -deadInterval -hellointerval -helloInterval \
        -instanceid -instanceId -networktype -interfaceType -optionvalue -routerOptions}
    array set ipaddr_attr_list {-ipaddr -ip -prefixlen -prefixLength}

    foreach {args_key args_value} [array get args_array] {
        upvar 1 $args_value $args_value
        set foundflag 0

        foreach {param_key ixnet_key} [array get router_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_router $ixnet_key]\n"
                set $args_value [ixNet getAttribute $sg_router $ixnet_key]
            }
        }

        foreach {param_key ixnet_key} [array get interface_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_interface $ixnet_key]\n"
                set $args_value [ixNet getAttribute $sg_interface $ixnet_key]
            }
        }

        foreach {param_key ixnet_key} [array get ipaddr_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_ipv6 $ixnet_key]\n"
                set $args_value [ixNet getAttribute $sg_ipv6 $ixnet_key]
            }
        }

        if {!$foundflag} {
            ixDebugPuts "The $args_key can not be found on currently attribute list\n"
            ixDebugPuts "The $args_key value will be set to Null\n"
            set $args_value "Null"
        }
    }

    ixDebugPuts "End of proc OspfV3Router::GetRouter...\n"
}

#=========================================================
# 函数名称:Enable by sigma 2009.4.16
# 描述: 使能指定的ospf Router
# 参数:
# 语法描述:
#    ospf1 Enable
# 返回值：
#   成功启动 OspfV3Router参数则返回1，否则返回0；
#========================================================

itcl::body OspfV3Router::Enable {args} {
    ixDebugPuts "Enter proc OspfV3Router::Enable...\n"
    set procname [lindex [info level [info level]] 0]

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    ixNet setAttribute $vport/protocols/ospfV3 -enabled True
    ixNet commit

    ixDebugPuts "End of proc OspfV3Router::Enable...\n"
    return $::SUCCESS
}

#========================================================
# 函数名称:Disable by sigma 2009.4.16
# 描述: 使能指定的ospf Router
# 参数:
# 语法描述:
#    ospf1 Disable
# 返回值：
#    成功关闭 OspfV3Router参数则返回1，否则返回0
#========================================================
itcl::body OspfV3Router::Disable {args} {
    ixDebugPuts "Enter proc OspfV3Router::Disable...\n"
    set procname [lindex [info level [info level]] 0]

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    ixNet setAttribute $vport/protocols/ospfV3 -enabled false
    ixNet commit

    ixDebugPuts "End of proc OspfV3Router::Disable...\n"
    return $::SUCCESS
}

#=======================================================
# 函数名称:AddTopGrid by sigma 2009.4.17
# 描述: 创建Ospf Grid拓扑
# 参数:
# StartingRouterID:     1.1.x.y (x代表行数 y代表列数, Grid中每个RouterID都可以这样表示)
# GridName:             OSPF Grip的名称标识 (要求在OSPF Router下属的所有GridName中唯一)
# GridRows:             模拟的OSPF Grid的行数
# GridColumns:          模拟的OSPF Grid的列数
# ConnectedGridRows:
# ConnectedGridColumns:
# Advertise:
# 语法描述:
#    ospf1 -GridRows 50 -GridColumns 100 -StartingRouterID 20.99
#    RouterOSPF AddTopGrid -GridName grid1 -GridRows 10 -GridColumns 10
# 返回值：
#    成功返回1，否则返回0
#=======================================================

itcl::body OspfV3Router::AddTopGrid {args} {
    ixDebugPuts "Enter proc OspfV3Router::AddTopGrid...\n"
    set args [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    #Default value setting
    set StartingRouterID "1.1"
    #set GridName "TopGrid" ;#No Found
    set GridRows 10
    set GridColumns 10
    set ConnectedGridRows 1
    set ConnectedGridColumns 1
    set Advertise "True"

    #判断参数是否存在并赋值
    #将路由器位置用x.y表示
    if {[info exists args_array(-startingrouterid)]} {
        set StartingRouterID $args_array(-startingrouterid)
    }
    set StartingRouterID "1.1.$StartingRouterID"
    lappend m_RouterId_List $StartingRouterID

    if {[info exists args_array(-gridname)]} {
        if {[lsearch $m_GridName_List $args_array(-gridname)] != "-1"} {
            set ::ERRINFO "$procname: There has exists same $args_array(-gridname) in the top grid list."
            error "$::ERRINFO"
            return $::FAILURE
        } else {
            set GridName $args_array(-gridname)
            lappend m_GridName_List $GridName
        }
    } else {
        set ::ERRINFO "$procname: Miss mandatory arg -GridName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[info exists args_array(-gridrows)]} {
        set GridRows $args_array(-gridrows)
    }

    if {[info exists args_array(-gridcolumns)]} {
        set GridColumns $args_array(-gridcolumns)
    }

    if {[info exists args_array(-connectedgridrows)]} {
        set ConnectedGridRows $args_array(-connectedgridrows)
    }

    if {[info exists args_array(-connectedgridcolumns)]} {
        set ConnectedGridColumns $args_array(-connectedgridcolumns)
    }

    if {[info exists args_array(-advertise)]} {
        if {[string is false $args_array(-advertise)] || [string is true $args_array(-advertise)]} {
            set Advertise $args_array(-advertise)
        }
    }

    ixDebugPuts "The ConnectedGridRows value is :  $ConnectedGridRows\n"
    ixDebugPuts "The ConnectedGridColumns value is :  $ConnectedGridColumns\n"
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]

    if {1} {
    set sg_networkrange [ixNet add $sg_router networkRange]
    #ixNet setMultiAttrs $sg_networkrange \
        -bBit False \
        -eBit False \
        -enableAdvertiseNetworkRange $Advertise \
        -entryAddress 0:0:0:0:0:0:0:0 \
        -entryColumn $ConnectedGridColumns \
        -entryMaskLength 64 \
        -entryRow $ConnectedGridRows \
        -incrementByRid 0.0.0.1 \
        -linkMetric 1 \
        -linkType broadcast \
        -numCols $GridColumns \
        -numRows $GridRows \
        -prefixAddress 0:0:0:0:0:0:0:0 \
        -prefixMask 64 \
        -rid $StartingRouterID
    ixNet setMultiAttrs $sg_networkrange \
        -bBit False \
        -eBit False \
        -enableAdvertiseNetworkRange False \
        -entryAddress 0:0:0:0:0:0:0:0 \
        -entryColumn 9 \
        -entryMaskLength 64 \
        -entryRow 8 \
        -incrementByRid 0.0.0.1 \
        -linkMetric 1 \
        -linkType broadcast \
        -numCols 18 \
        -numRows 17 \
        -prefixAddress 0:0:0:0:0:0:0:0 \
        -prefixMask 64 \
        -rid 0.0.0.1
    } else {
    set sg_networkrange [ixNet add $sg_router networkRange]
    ixNet setMultiAttrs $sg_networkrange \
        -enableAdvertiseNetworkRange $Advertise \
        -entryColumn $ConnectedGridColumns \
        -entryRow $ConnectedGridRows \
        -numCols $GridColumns \
        -numRows $GridRows \
        -rid $StartingRouterID
    }
    ixNet commit
    set m_sg_networkrange [lindex [ixNet remapIds $sg_networkrange] 0]

    ixDebugPuts "End of proc OspfV3Router::AddTopGrid...\n"
    return $::SUCCESS
}

#================================================================
# 函数名称:GetTopGrid by sigma 2009.4.17
# 描述: 获取iOspf Grid拓扑的属性值
# 参数:
# StartingRouterID:     1.1.x.y (x代表行数 y代表列数, Grid中每个RouterID都可以这样表示)
# GridName:             OSPF Grip的名称标识 (要求在OSPF Router下属的所有GridName中唯一)
# GridRows:             模拟的OSPF Grid的行数
# GridColumns:          模拟的OSPF Grid的列数
# ConnectedGridRows:
# ConnectedGridColumns:
# RouterIdList:
# Advertise:
# 语法描述:
#    odpf1 GetTopGrid -GridName xxx
# 返回值：
#    返回对应的array
#================================================================
itcl::body OspfV3Router::GetTopGrid {args} {
    ixDebugPuts "Enter proc OspfV3Router::GetTopGrid...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {![info exists args_array(-gridname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -GridName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[lsearch $m_GridName_List $args_array(-gridname)] == "-1"} {
        set ::ERRINFO "no this gridname($args_array(-gridname)) in the grid list\n"
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set GridName $args_array(-gridname)
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_networkrange [lindex [ixNet getList $sg_router networkRange] \
        [lsearch $m_GridName_List $GridName]]

    array set networkrange_attr_list {-startingrouterid -rid -gridrows -numRows -gridcolumns -numCols \
        -connectedgridrows -entryRow -connectedgridcolumns -entryColumn -advertise -enableAdvertiseNetworkRange}

    foreach {args_key args_value} [array get args_array] {
        upvar 1 $args_value $args_value
        set foundflag 0

        if {$args_key == "-routeridlist"} {
            set foundflag 1
            set $args_value $m_RouterId_List
        } elseif {$args_key == "-gridname"} {
            set foundflag 1
            continue
        }

        foreach {param_key ixnet_key} [array get networkrange_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_networkrange $ixnet_key]\n"
                set $args_value [ixNet getAttribute $sg_networkrange $ixnet_key]
            }
        }

        if {!$foundflag} {
            ixDebugPuts "The $args_key can not be found on currently attribute list\n"
            ixDebugPuts "The $args_key value will be set to Null\n"
            set $args_value "Null"
        }
    }

    ixDebugPuts "End of proc OspfV3Router::GetTopGrid...\n"
}

#==================================================================
# 函数名称:RemoveTopGrid by sigma 2009.4.20
# 描述: 删除ospfRotuer相应的Grid
# 参数:
# 语法描述:
#    odpf1 RemoveTopGrid -GridName xxx
# 返回值：
#    成功删除返回1
#==================================================================
itcl::body OspfV3Router::RemoveTopGrid {args} {
    ixDebugPuts "Enter proc OspfV3Router::RemoveTopGrid...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {![info exists args_array(-gridname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -GridName."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set GridName $args_array(-gridname)
    }

    if {[lsearch $m_GridName_List $args_array(-gridname)] == "-1"} {
        ixDebugPuts "no this gridname($args_array(-gridname)) in the grid list\n"
        return $::FAILURE
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_networkrange [lindex [ixNet getList $sg_router networkRange] \
        [lsearch $m_GridName_List $GridName]]

    ixNet setAttribute $sg_networkrange -enableAdvertiseNetworkRange false
    ixNet remove $sg_networkrange
    ixNet commit

    set m_GridName_List [lreplace $m_GridName_List \
        [lsearch $m_GridName_List $GridName] [lsearch $m_GridName_List $GridName]]

    ixDebugPuts "End of proc OspfV3Router::RemoveTopGrid...\n"
    return $::SUCCESS
}

#==================================================================
# 函数名称:CreateUserLsa by sigma 2009.4.21
# 描述: 创建Ospf Router拓扑
# 参数:
# RouterID:              添加的路由器ID
# RouterLsaName:
# RouterName:
# 语法描述:
#    ospf1 CreateUserLsa -RouterName “myrouter” -RouterId 10 -RouterTypeValue ASBR
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::CreateUserLsa {args} {
    ixDebugPuts "Enter proc OspfV3Router::CreateUserLsa...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {![info exists args_array(-routerlsaname)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterLsaName."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterLsaName $args_array(-routerlsaname)
        if {[lsearch $m_userLsaGroup_List $args_array(-routerlsaname)] != "-1"} {
            ixDebugPuts "$procname: There has exists same $args_array(-routerlsaname) in the User Lsa Group list."
            set UserLsgGroupFlag 0
        } else {
            set UserLsgGroupFlag 1
            lappend m_userLsaGroup_List $RouterLsaName
        }
    }

    if {![info exists args_array(-lsatype)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -LsaType."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set LsaType $args_array(-lsatype)
    }

    if {![info exists args_array(-routerid)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterID."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterID $args_array(-routerid)
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]

    if {$UserLsgGroupFlag} {
        set sg_userLsaGroup [ixNet add $sg_router userLsaGroup]
        ixNet setMultiAttrs $sg_userLsaGroup \
            -areaId $m_userLsaGroup_Seq \
            -description $RouterLsaName \
            -enabled True
        ixNet commit
        set m_sg_userLsaGroup [lindex [ixNet remapIds $sg_userLsaGroup] 0]
    } else {
        set m_sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] \
            [lsearch $m_userLsaGroup_List $RouterLsaName]]
    }

    set sg_userLsa [ixNet add $m_sg_userLsaGroup userLsa]
    #ixNet setMultiAttrs $sg_userLsa \
        -advertisingRouterId $RouterID \
        -enabled True \
        -linkStateId $RouterID \
        -lsaType $LsaType

    ixNet setMultiAttrs $sg_userLsa \
        -advertisingRouterId $RouterID \
        -enabled True \
        -lsaType $LsaType
    ixNet commit
    set m_sg_userLsa [lindex [ixNet remapIds $sg_userLsa] 0]

    ixDebugPuts "End of proc OspfV3Router::CreateUserLsa...\n"
    return $m_sg_userLsa
}

#==================================================================
# 函数名称:AddTopRouter by sigma 2009.4.21
# 描述: 创建Ospf Router拓扑
# 参数:
# RouterID:              添加的路由器ID
# RouterTypeValue:       添加的路由器类型，值为abr，asbr
# RouterLsaName:
# RouterName:
# 语法描述:
#    ospf1 AddTopRouter -RouterName “myrouter” -RouterId 10 -RouterTypeValue ASBR
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::AddTopRouter {args} {
    ixDebugPuts "Enter proc OspfV3Router::AddTopRouter...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set RouterID "0.0.0.$m_userLsaGroup_Seq"
    set RouterLsaName "ospfv3group"
    set RouterName "Router$m_userLsaGroup_Seq"

    if {![info exists args_array(-routertypevalue)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterTypeValue."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterTypeValue [string tolower $args_array(-routertypevalue)]
        ixDebugPuts "0.Dedug, RouterTypeValue: $RouterTypeValue\n"
        if {$RouterTypeValue == "asbr"} {
            set RouterTypeValue "True"
        } else {
            set RouterTypeValue "False"
        }
    }

    if {[info exists args_array(-routerid)]} {
        set RouterID $args_array(-routerid)
    }
    #lappend m_userLsaRouterID_List $RouterID

    if {[info exists args_array(-routerlsaname)]} {
        set RouterLsaName $args_array(-routerlsaname)
    }

    if {[info exists args_array(-routername)]} {
        if {[lsearch $m_userLsaRouterName_List $args_array(-routername)] != "-1"} {
            set ::ERRINFO "$procname: There has exists same $args_array(-routername) in the top router list."
            error "$::ERRINFO"
            return $::FAILURE
        } else {
            set RouterName $args_array(-routername)
            lappend m_userLsaRouterName_List $RouterName
        }
    } else {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterName."
        error "$::ERRINFO"
        return $::FAILURE
    }
    if {0} {
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]

    ixDebugPuts "1.Dedug, RouterTypeValue: $RouterTypeValue\n"
    set sg_userLsaGroup [ixNet add $sg_router userLsaGroup]
    ixNet setMultiAttrs $sg_userLsaGroup \
        -areaId $m_userLsaGroup_Seq \
        -description $RouterLsaName \
        -enabled True
    ixNet commit
    set m_sg_userLsaGroup [lindex [ixNet remapIds $sg_userLsaGroup] 0]

    set sg_userLsa [ixNet add $m_sg_userLsaGroup userLsa]
    ixNet setMultiAttrs $sg_userLsa \
        -advertisingRouterId $RouterID \
        -enabled True \
        -linkStateId $RouterID \
        -lsaType router
    ixNet commit
    set m_sg_userLsa [lindex [ixNet remapIds $sg_userLsa] 0]
    } else {
        set m_sg_userLsa [CreateUserLsa -RouterLsaName $RouterLsaName -LsaType router \
            -RouterID $RouterID]
    }

    set sg_lsarouter $m_sg_userLsa/router
    if {0} {
    ixNet setMultiAttrs $sg_lsarouter \
        -bBit False \
        -eBit $RouterTypeValue \
        -interfaces  {  } \
        -optBitDc False \
        -optBitE $RouterTypeValue \
        -optBitMc False \
        -optBitN False \
        -optBitR False \
        -optBitV6 False \
        -option 0 \
        -vBit False \
        -wBit False
    } else {
    ixNet setMultiAttrs $sg_lsarouter \
        -eBit $RouterTypeValue \
        -optBitE $RouterTypeValue
    }
    ixNet commit
    set m_sg_lsarouter [lindex [ixNet remapIds $sg_lsarouter] 0]
    incr m_userLsaGroup_Seq

    ixDebugPuts "End of proc OspfV3Router::AddTopRouter...\n"
    return $::SUCCESS
}

#================================================================
# 函数名称:GetTopRouter by sigma 2009.4.22
# 描述: 获取ospfRotuer相应的Gridrouter的属性信息
# 参数:
# 语法描述:
#    ospf1 GetTopRouter -RouterName $Router1
# 返回值：
#    返回对应的array
#================================================================
itcl::body OspfV3Router::GetTopRouter {args} {
    ixDebugPuts "Enter proc OspfV3Router::GetTopRouter...\n"
    set args [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    ixDebugPuts "The tolower args paramter is: $args\n"

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {![info exists args_array(-routername)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[lsearch $m_userLsaRouterName_List $args_array(-routername)] == "-1"} {
        set ::ERRINFO "no this routername($args_array(-routername)) in the routename list\n"
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterName $args_array(-routername)
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] \
        [expr [llength $m_userLsaGroup_List] -1]]
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] \
        [lsearch $m_userLsaRouterName_List $RouterName]]

    array set sg_userlsagourp_attr_list {-routerlsaname -description}
    array set sg_userlsa_attr_list {-routerid -advertisingRouterId}
    array set sg_userlsa_router_attr_list {-routertypevalue -optBitE}

    foreach {args_key args_value} [array get args_array] {
        upvar 1 $args_value $args_value
        set foundflag 0

        if {$args_key == "-routername"} {
            set foundflag 1
            continue
        }

        foreach {param_key ixnet_key} [array get sg_userlsagourp_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_userLsaGroup $ixnet_key]\n"
                set $args_value [ixNet getAttribute $sg_userLsaGroup $ixnet_key]
            }
        }

        foreach {param_key ixnet_key} [array get sg_userlsa_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_userLsa $ixnet_key]\n"
                set $args_value [ixNet getAttribute $sg_userLsa $ixnet_key]
            }
        }

        foreach {param_key ixnet_key} [array get sg_userlsa_router_attr_list] {
            if {$param_key == $args_key} {
                set foundflag 1
                ixDebugPuts "The $args_key value is [ixNet getAttribute $sg_userLsa/router $ixnet_key]\n"
                set Temp [ixNet getAttribute $sg_userLsa/router $ixnet_key]
                puts "3 Debug: ixnet_key: $ixnet_key, Temp: $Temp"
                if {$ixnet_key == "-optBitE" && [string equal -nocase $Temp "true"]} {
                    set $args_value "asbr"
                } elseif {$ixnet_key == "-optBitE" && [string equal -nocase $Temp "false"]} {
                    set $args_value "abr"
                } else {
                    set $args_value [ixNet getAttribute $sg_userLsa/router $ixnet_key]
                }
            }
        }

        if {!$foundflag} {
            ixDebugPuts "The $args_key can not be found on currently attribute list\n"
            ixDebugPuts "The $args_key value will be set to Null\n"
            set $args_value "Null"
        }
    }

    ixDebugPuts "End of proc OspfV3Router::GetTopRouter...\n"
}

#==================================================================
# 函数名称:RemoveTopRouter by sigma 2009.4.20
# 描述: 删除ospfRotuer相应的Grid
# 参数:
# 语法描述:
#    odpf1 RemoveTopRouter -RouterName myRouter
# 返回值：
#    成功删除返回1
#==================================================================
itcl::body OspfV3Router::RemoveTopRouter {args} {
    ixDebugPuts "Enter proc OspfV3Router::RemoveTopRouter...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {![info exists args_array(-routername)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[lsearch $m_userLsaRouterName_List $args_array(-routername)] == "-1"} {
        set ::ERRINFO "no this routername($args_array(-routername)) in the routename list\n"
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterName $args_array(-routername)
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] \
        [expr [llength $m_userLsaGroup_List] -1]]
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] \
        [lsearch $m_userLsaRouterName_List $RouterName]]

    #ixNet setAttribute $sg_userLsa -enableAdvertiseNetworkRange false
    ixNet remove $sg_userLsa
    ixNet commit

    set m_userLsaRouterName_List [lreplace $m_userLsaRouterName_List \
        [lsearch $m_userLsaRouterName_List $RouterName] [lsearch $m_userLsaRouterName_List $RouterName]]

    ixDebugPuts "End of proc OspfV3Router::RemoveTopRouter...\n"
    return $::SUCCESS
}

#==================================================================
# 函数名称:AddTopRouterLink by sigma 2009.4.21
# 描述: 创建Ospf Router拓扑
# 参数:
# RouterID
# RouterName
# LinkType
# LinkInterfaceId
# NeighborInterfaceId
# FlagAdvertise
# NeighborRouterId
# IinkInterfaceAddress
# LinkMetric
# 语法描述:
#    ospf1 AddTopRouterLink -RouterName Router1 -LinkType Broadcast
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::AddTopRouterLink {args} {
    ixDebugPuts "Enter proc OspfV3Router::AddTopRouterLink...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set RouterID ""
    set LinkType "transit"
    set LinkInterfaceId 0
    set NeighborInterfaceId 0
    set FlagAdvertise "" ; #No Found
    set NeighborRouterId 0.0.0.0
    set IinkInterfaceAddress "" ; #No Found
    set LinkMetric 0
    set RouterLsaName [lindex $m_userLsaGroup_List [expr [llength $m_userLsaGroup_List] - 1]]

    if {[info exists args_array(-linktype)]} {
        set LinkType $args_array(-linktype)
    }

    if {[info exists args_array(-routerid)]} {
        set RouterID $args_array(-routerid)
    }
    
    if {[info exists args_array(-linkinterfaceid)]} {
        set LinkInterfaceId $args_array(-linkinterfaceid)
    }
    lappend m_TopRouterLink_InterID_List $LinkInterfaceId

    if {[info exists args_array(-neighborinterfaceid)]} {
        set NeighborInterfaceId $args_array(-neighborinterfaceid)
    }

    if {[info exists args_array(-neighborrouterid)]} {
        set NeighborRouterId $args_array(-neighborrouterid)
    }
    
    if {[info exists args_array(-linkmetric)]} {
        set LinkMetric $args_array(-linkmetric)
    }
    
    if {![info exists args_array(-routername)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterName."
        error "$::ERRINFO"
        return $::FAILURE
    }
    
    if {[lsearch $m_userLsaRouterName_List $args_array(-routername)] == "-1"} {
        set ::ERRINFO "no this routername($args_array(-routername)) in the routename list\n"
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterName $args_array(-routername)
    }
    
    lappend m_TopRouterLink_InterAttr_List [list $LinkInterfaceId $NeighborInterfaceId $NeighborRouterId \
        $LinkType $LinkMetric]
    #set m_TopRouterLink_InterAttr_List "$m_TopRouterLink_InterAttr_List [list $LinkInterfaceId $NeighborInterfaceId $NeighborRouterId \
        $LinkType $LinkMetric]"
    ixDebugPuts "m_TopRouterLink_InterAttr_List: [list " $m_TopRouterLink_InterAttr_List "]\n"
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] \
        [expr [llength $m_userLsaGroup_List] -1]]
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] \
        [lsearch $m_userLsaRouterName_List $RouterName]]
    
    if {$RouterID != ""} {
        ixNet setAttribute $sg_userLsa \
            -advertisingRouterId $RouterID
        ixNet commit
        set sg_userLsa [lindex [ixNet remapIds $sg_userLsa] 0]
    }
    
    set sg_lsarouter $sg_userLsa/router
    ixNet setAttribute $sg_lsarouter -interfaces $m_TopRouterLink_InterAttr_List
    ixNet commit
    set m_sg_lsarouter [lindex [ixNet remapIds $sg_lsarouter] 0]

    ixDebugPuts "End of proc OspfV3Router::AddTopRouterLink...\n"
    return $::SUCCESS
}

#==================================================================
# 函数名称:RemoveTopRouterLink by sigma 2009.4.21
# 描述: 创建Ospf Router拓扑
# 参数:
# RouterName
# LinkInterfaceId
# 语法描述:
#    ospf1 RemoveTopRouterLink -RouterName Router1 -LinkInterfaceId 77
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::RemoveTopRouterLink {args} {
    ixDebugPuts "Enter proc OspfV3Router::RemoveTopRouterLink...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }
    
    if {![info exists args_array(-linkinterfaceid)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -LinkInterfaceId."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[lsearch $m_TopRouterLink_InterID_List $args_array(-linkinterfaceid)] == "-1"} {
        set ::ERRINFO "no this LinkInterfaceId($args_array(-linkinterfaceid)) in the LinkInterfaceId list\n"
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set LinkInterfaceId $args_array(-linkinterfaceid)
    }

    if {![info exists args_array(-routername)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -RouterName."
        error "$::ERRINFO"
        return $::FAILURE
    }
    
    if {[lsearch $m_userLsaRouterName_List $args_array(-routername)] == "-1"} {
        set ::ERRINFO "no this routername($args_array(-routername)) in the routename list\n"
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set RouterName $args_array(-routername)
    }
    
    set count 0
    foreach param $m_TopRouterLink_InterAttr_List {
        if {[lindex $param 0] == $LinkInterfaceId} {
            set m_TopRouterLink_InterAttr_List [lreplace $m_TopRouterLink_InterAttr_List $count $count]
            ixDebugPuts "m_TopRouterLink_InterAttr_List: [list " $m_TopRouterLink_InterAttr_List "]\n"
            break
        }
        incr count
    }
    
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] \
        [expr [llength $m_userLsaGroup_List] -1]]
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] \
        [lsearch $m_userLsaRouterName_List $RouterName]]
    
    set sg_lsarouter $sg_userLsa/router
    ixNet setAttribute $sg_lsarouter -interfaces $m_TopRouterLink_InterAttr_List
    ixNet commit
    set m_sg_lsarouter [lindex [ixNet remapIds $sg_lsarouter] 0]

    ixDebugPuts "End of proc OspfV3Router::RemoveTopRouterLink...\n"
    return $::SUCCESS
}

#==================================================================
# 函数名称:AddTopNetwork by sigma 2009.4.21
# 描述: 创建Ospf Router拓扑
# 参数:
# NetworkName
# Subnetwork
# Prefix
# DRRouterName
# ConnectedRouterNameList   这个网络上所有的路由器名字
# LsaName                   对应的Lsa名字
# 语法描述:
#    ospf1 AddTopNetwork -RouterName “myrouter” -RouterId 10 -RouterTypeValue ASBR
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::AddTopNetwork {args} {
    ixDebugPuts "Enter proc OspfV3Router::AddTopNetwork...\n"
    set args [ixConvertToLowerCase $args]
    ixDebugPuts "The tolower args paramter is: $args\n"
    set procname [lindex [info level [info level]] 0]

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set Subnetwork "" ; #No Found
    set Prefix "" ; #No Found
    set DRRouterName "" ; #No Found
    set ConnectedRouterNameList "" ; #No Found
    set RouterID "0.0.0.$m_userLsaGroup_Seq"
    set LsaName "ospfv3group"

    if {[info exists args_array(-routerid)]} {
        set RouterID $args_array(-routerid)
    }

    if {[info exists args_array(-lsaname)]} {
        set LsaName $args_array(-lsaname)
    }

    if {[info exists args_array(-networkname)]} {
        if {[lsearch $m_userLsaRouterName_List $args_array(-networkname)] != "-1"} {
            set ::ERRINFO "$procname: There has exists same $args_array(-networkname) in the top router list."
            error "$::ERRINFO"
            return $::FAILURE
        } else {
            set NetworkName $args_array(-networkname)
            lappend m_userLsaRouterName_List $NetworkName
        }
    } else {
        set ::ERRINFO "$procname: Miss mandatory arg -NetworkName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set m_sg_userLsa [CreateUserLsa -RouterLsaName $LsaName -LsaType network \
        -RouterID $RouterID]

    set sg_lsarouter $m_sg_userLsa/router
    if {0} {
    ixNet setMultiAttrs $sg_lsarouter \
        -bBit False \
        -eBit $RouterTypeValue \
        -interfaces  {  } \
        -optBitDc False \
        -optBitE $RouterTypeValue \
        -optBitMc False \
        -optBitN False \
        -optBitR False \
        -optBitV6 False \
        -option 0 \
        -vBit False \
        -wBit False
    } else {
    ixNet setMultiAttrs $sg_lsarouter \
        -eBit $RouterTypeValue \
        -optBitE $RouterTypeValue
    }
    ixNet commit
    set m_sg_lsarouter [lindex [ixNet remapIds $sg_lsarouter] 0]
    incr m_userLsaGroup_Seq

    ixDebugPuts "End of proc OspfV3Router::AddTopNetwork...\n"
    return $::SUCCESS
}

if {0} {
#==================================================================
# 函数名称:CreateTopInterAreaPrefixRouteBlock by sigma 2009.5.4
# 描述: 创建Ospf Network拓扑
# 参数:
# BlockName
# StartingAddress
# Prefix
# Numbner
# Modifier
# FlagPBit
# FlagNuBit
# FlagLaBit
# FlagTrafficDest
# 语法描述:
#    ospf1 CreateTopInterAreaPrefixRouteBlock -BlockName mypool
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::CreateTopInterAreaPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::CreateTopInterAreaPrefixRouteBlock...\n"
    set args [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    ixDebugPuts "The tolower args paramter is: $args\n"

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set RouterLsaName [lindex $m_userLsaGroup_List [expr [llength $m_userLsaGroup_List] - 1]]
    #set RouterID [lindex $m_userLsaRouterID_List [expr [llength $m_userLsaRouterID_List] - 1]]
    set Prefix 1
    set Numbner 1
    set Modifier 1
    set FlagPBit "False"
    set FlagNuBit "False"
    set FlagLaBit "False"
    set FlagTrafficDest "" ;#No found

    if {![info exists args_array(-startingaddress)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -StartingAddress."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set StartingAddress $args_array(-startingaddress)
    }

    if {[info exists args_array(-blockname)]} {
        if {[lsearch $m_userLsaRouterName_List $args_array(-blockname)] != "-1"} {
            set ::ERRINFO "$procname: There has exists same $args_array(-BlockName) in the top router list."
            error "$::ERRINFO"
            return $::FAILURE
        } else {
            set BlockName $args_array(-blockname)
            lappend m_userLsaRouterName_List $BlockName
        }
    } else {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[info exists args_array(-prefix)]} {
        set Prefix $args_array(-prefix)
    }
    set addressPrefix "0:0:0:0:0:0:0:$Prefix"

    if {[info exists args_array(-numbner)]} {
        set Numbner $args_array(-numbner)
    }

    if {[info exists args_array(-modifier)]} {
        set Modifier $args_array(-modifier)
    }

    if {[info exists args_array(-flagpbit)]} {
        set FlagPBit $args_array(-flagpbit)
    }

    if {[info exists args_array(-flagnubit)]} {
        set FlagNuBit $args_array(-flagnubit)
    }

    if {[info exists args_array(-flaglabit)]} {
        set FlagLaBit $args_array(-flaglabit)
    }

    set m_sg_userLsa [CreateUserLsa -RouterLsaName $RouterLsaName -LsaType interAreaPrefix \
            -RouterID $StartingAddress]

    set sg_interAreaPrefix $m_sg_userLsa/interAreaPrefix
    ixNet setMultiAttrs $sg_interAreaPrefix \
         -addPrefixLength 64 \
         -addressPrefix $addressPrefix \
         -incrLinkStateId 0.0.0.0 \
         -lsaCount $Numbner \
         -metric 1 \
         -optBitLa $FlagLaBit \
         -optBitMc False \
         -optBitNu $FlagNuBit \
         -optBitP $FlagPBit \
         -option 0 \
         -prefixAddressIncrementBy $Modifier
    ixNet commit
    set m_sg_interAreaPrefix [lindex [ixNet remapIds $sg_interAreaPrefix] 0]

    ixDebugPuts "End of proc OspfV3Router::CreateTopInterAreaPrefixRouteBlock...\n"
    return $::SUCCESS
}

#==================================================================
# 函数名称:ConfigTopInterAreaPrefixRouteBlock by sigma 2009.5.4
# 描述: 创建Ospf Network拓扑
# 参数:
# BlockName
# StartingAddress
# Prefix
# Numbner
# Modifier
# FlagPBit
# FlagNuBit
# FlagLaBit
# FlagTrafficDest
# 语法描述:
#    ospf1 ConfigTopInterAreaPrefixRouteBlock -BlockName mypool
# 返回值：
#    成功返回1
#==================================================================
itcl::body OspfV3Router::ConfigTopInterAreaPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::ConfigTopInterAreaPrefixRouteBlock...\n"
    set args [ixConvertToLowerCase $args]
    set procname [lindex [info level [info level]] 0]
    ixDebugPuts "The tolower args paramter is: $args\n"

    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        error "$::ERRINFO"
        return $::FAILURE
    }

    set RouterLsaName [lindex $m_userLsaGroup_List [expr [llength $m_userLsaGroup_List] - 1]]
    set Prefix 1
    set Numbner 1
    set Modifier 1
    set FlagPBit "False"
    set FlagNuBit "False"
    set FlagLaBit "False"
    set FlagTrafficDest "" ;#No found

    if {![info exists args_array(-startingaddress)]} {
        set ::ERRINFO "$procname: Miss mandatory arg -StartingAddress."
        error "$::ERRINFO"
        return $::FAILURE
    } else {
        set StartingAddress $args_array(-startingaddress)
    }

    if {[info exists args_array(-blockname)]} {
        if {[lsearch $m_userLsaRouterName_List $args_array(-blockname)] == "-1"} {
            set ::ERRINFO "no this routername($args_array(-blockname)) in the routename list\n."
            error "$::ERRINFO"
            return $::FAILURE
        } else {
            set BlockName $args_array(-blockname)
        }
    } else {
        set ::ERRINFO "$procname: Miss mandatory arg -BlockName."
        error "$::ERRINFO"
        return $::FAILURE
    }

    if {[info exists args_array(-prefix)]} {
        set Prefix $args_array(-prefix)
    }
    set addressPrefix "0:0:0:0:0:0:0:$Prefix"

    if {[info exists args_array(-numbner)]} {
        set Numbner $args_array(-numbner)
    }

    if {[info exists args_array(-modifier)]} {
        set Modifier $args_array(-modifier)
    }

    if {[info exists args_array(-flagpbit)]} {
        set FlagPBit $args_array(-flagpbit)
    }

    if {[info exists args_array(-flagnubit)]} {
        set FlagNuBit $args_array(-flagnubit)
    }

    if {[info exists args_array(-flaglabit)]} {
        set FlagLaBit $args_array(-flaglabit)
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] 0]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] \
        [lsearch $m_userLsaRouterName_List $RouterName]]

    set m_sg_userLsa [CreateUserLsa -RouterLsaName $RouterLsaName -LsaType interAreaPrefix \
            -RouterID $StartingAddress]

    set sg_interAreaPrefix [lindex [lindex [ixNet getList $sg_userLsaGroup userLsa] 0]

    set sg_interAreaPrefix $m_sg_userLsa/interAreaPrefix
    ixNet setMultiAttrs $sg_interAreaPrefix \
         -addPrefixLength 64 \
         -addressPrefix $addressPrefix \
         -incrLinkStateId 0.0.0.0 \
         -lsaCount $Numbner \
         -metric 1 \
         -optBitLa $FlagLaBit \
         -optBitMc False \
         -optBitNu $FlagNuBit \
         -optBitP $FlagPBit \
         -option 0 \
         -prefixAddressIncrementBy $Modifier
    ixNet commit
    set m_sg_interAreaPrefix [lindex [ixNet remapIds $sg_interAreaPrefix] 0]

    ixDebugPuts "End of proc OspfV3Router::ConfigTopInterAreaPrefixRouteBlock...\n"
    return $::SUCCESS
}
}


#================================================================
# 函数名称:#CreateTopExternalPrefixRouteBlock by sigma 2009.5.5
# 描述: 创建ExternalPrefixRouteLsa的属性信息
# 参数:
# BlockName            创建Block标识 必选
# Metric               AS External的Metric字段
# Number               AS External的Number of LSA字段
# Prefix               AS External的address Prefix字段,IPv6形式 eg：2:2:2:2:2:2:2:2
# StartingAddress      AS External的LinkStateId字段,IPv4形式 eg：1.1.1.1
# Modifier             AS External的Increment ID字段,IPv4形式 eg：1.1.1.1
# FlagFbit             Fbit true or false
# FowardingAddress     AS External的FowardingAddress字段,IPv6形式 eg：2:2:2:2:2:2:2:2
# FlagASBR             ebit true or false
# AdvertisingRouterID  AS External的AdvertisingRouterID字段,IPv4形式 eg：1.1.1.1
# MetricType           AS External的 LS type字段：Ignore，routerLsa，Networklsa
# ExternalRouteTag     AS External的External Route Tag字段,IPv4形式 eg：1.1.1.1
# FlagTbit             Tbit true or false
# FlagNuBit            Nubit true or false
# FlagLaBit            Labit true or false
# FlagNssa             Pbit true or false
# 语法描述:
#    ospfv31 CreateTopExternalPrefixRouteBlock -BlockName a -Numbner 10
# 返回值：
#    成功返回0
#================================================================
itcl::body OspfV3Router::CreateTopExternalPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::CreateTopExternalPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    #set args [ixConvertToLowerCase $args]
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    } 
    
    if {![info exists args_array(-BlockName)]} {
        puts "CreateTopExternalPrefixRouteBlock need input BlockName!, process stop"
        return $::FAILURE
    } elseif {[lsearch $m_userLsaRouterName_List $args_array(-BlockName)]!=-1} {
        puts "This Name already exist! process stop"
        return $::FAILURE
    } else {
        lappend m_userLsaRouterName_List $args_array(-BlockName)
    }    

    if {![info exists args_array(-StartingAddress)]} {
        set StartingAddress 0.0.0.0
    } else {
        set StartingAddress $args_array(-StartingAddress)
    }

    if {![info exists args_array(-Prefix)]} {
        set Prefix 0:0:0:0:0:0:0:0
    } else {
        set Prefix $args_array(-Prefix)
    }

    if {![info exists args_array(-Numbner)]} {
        set Number 1
    } else {
        set Number $args_array(-Number)
    }

    if {![info exists args_array(-Modifier)]} {
        set Modifier 0.0.0.0
    } else {
        set Modifier $args_array(-Modifier)
    }

    if {![info exists args_array(-FowardingAddress)]} {
        set FowardingAddress 0:0:0:0:0:0:0:0
    } else {
        set FowardingAddress $args_array(-FowardingAddress)
    }
   
    if {![info exists args_array(-FlagFbit)] || \
        [string match -nocase true $args_array(-FlagFbit)]} {
        set FlagFbit false
    } else {
        set FlagFbit true
    }    
    
    if {![info exists args_array(-FlagASBR)] || \
        [string match -nocase true $args_array(-FlagASBR)]} {
        set FlagASBR false
    } else {
        set FlagASBR true
    }    

    if {![info exists args_array(-FlagTbit)] || \
        [string match -nocase true $args_array(-FlagTbit)]} {
        set FlagTbit false
    } else {
        set FlagTbit true
    }

    if {![info exists args_array(-FlagNuBit)] || \
        [string match -nocase true $args_array(-FlagNuBit)]} {
        set FlagNuBit false
    } else {
        set FlagNuBit true
    }

    if {![info exists args_array(-FlagLaBit)] || \
        [string match -nocase true $args_array(-FlagLaBit)]} {
        set FlagLaBit false
    } else {
        set FlagLaBit true
    }

    if {![info exists args_array(-FlagNssa)] || \
        [string match -nocase true $args_array(-FlagNssa)]} {
        set FlagNssa false
    } else {
        set FlagNssa true
    }

    if {![info exists args_array(-FlagTranslatePropagateType7)] || \
        [string match -nocase true $args_array(-FlagTranslatePropagateType7)]} {
        set FlagTranslatePropagateType7 false
    } else {
        set FlagTranslatePropagateType7 true
    }

    if {![info exists args_array(-ExternalRouteTag)]} {
        set ExternalRouteTag 0.0.0.0
    } else {
        set ExternalRouteTag $args_array(-ExternalRouteTag)
    }

    if {![info exists args_array(-AdvertisingRouterID)]} {
        set AdvertisingRouterID 0.0.0.0
    } else {
        set AdvertisingRouterID $args_array(-AdvertisingRouterID)
    }

    if {![info exists args_array(-MetricType)] || \
        [string match -nocase ignore $args_array(-MetricType)]} {
        set MetricType ignore
    } elseif {[string match -cocase networklsa $args_array(-MetricType)] || \
        [string match -nocase routerLsa $args_array(-MetricType)]} {
        set MetricType $args_array(-MetricType)]
    } else {
        puts "Type should be ignore, routerlsa or networklsa"
        return $::FAILURE
    }
    
    if {![info exists args_array(-Metric)] || \
        ![string is integer $args_array(-Metric)]} {
        set Metric 0
    } else {
        set Metric $args_array(-Metric)
    }    

    #下面是定位到存在的最后一个router
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    if {$router_id == -1} {
        puts "no router exists, pls add router first"
    } else {
        set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    }
    
    set lsaGroupId [expr ([llength [ixNet getList $sg_router userLsaGroup]]-1)]
    if {$lsaGroupId == -1} {
        set sg_userLsaGroup [ixNet add $sg_router userLsaGroup]
    } else {
        set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId]
    }
    
    set sg_userLsa [ixNet add $sg_userLsaGroup userLsa]
    ixNet setAttribute $sg_userLsa  -advertisingRouterId  $AdvertisingRouterID
    ixNet setAttribute $sg_userLsa  -enabled true
    ixNet setAttribute $sg_userLsa  -linkStateId  $StartingAddress
    ixNet setAttribute $sg_userLsa  -lsaType asExternal
    ixNet commit
    
    set sg_asExternal $sg_userLsa/asExternal
    ixNet setAttribute $sg_asExternal  -addPrefix $Prefix
    ixNet setAttribute $sg_asExternal  -lsaCount $Number
    ixNet setAttribute $sg_asExternal  -incrLinkStateId $Modifier
    ixNet setAttribute $sg_asExternal  -fBit $FlagFbit
    ixNet setAttribute $sg_asExternal  -forwardingAddress $FowardingAddress
    ixNet setAttribute $sg_asExternal  -eBit $FlagASBR
    ixNet setAttribute $sg_asExternal  -referenceLsType $MetricType
    ixNet setAttribute $sg_asExternal  -metric $Metric
    ixNet setAttribute $sg_asExternal  -externalRouteTag $ExternalRouteTag
    ixNet setAttribute $sg_asExternal  -optBitNu $FlagNuBit
    ixNet setAttribute $sg_asExternal  -optBitLa $FlagLaBit
    ixNet setAttribute $sg_asExternal  -optBitP $FlagNssa
    ixNet setAttribute $sg_asExternal  -tBit $FlagTbit
    ixNet commit
    set m_sg_asExternal [lindex [ixNet remapIds $sg_asExternal] 0]
    return $::SUCCESS    
}

#================================================================
# 函数名称:DeleteTopExternalPrefixRouteBlock by sigma 2009.5.5
# 描述: 删除ExternalPrefixRouteBlock
# 参数:
# BlockName            要删除的Block标识 必选
# 语法描述:
#    ospfv31 DeleteTopExternalPrefixRouteBlock -BlockName a
# 返回值：
#    成功返回0
#================================================================
itcl::body OspfV3Router::DeleteTopExternalPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::DeleteTopExternalPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    } 
 
    #检查BlockName是否存在
    if {[info exists args_array(-BlockName)] && \
        [lsearch $m_userLsaRouterName_List $args_array(-BlockName)] != -1} {
        set deleteid [lsearch $m_userLsaRouterName_List $args_array(-BlockName)]
    } else {
        puts "Need input BlockName or BlockName not exist, process stop"
        return $::FAILURE
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId] 
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    set m_sg_router [lindex [ixNet remapIds $sg_router] 0] 
    set lsaGroupId [expr ([llength [ixNet getList $m_sg_router userLsaGroup]]-1)]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId] 
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] $deleteid] 
    #判断删除的是否为ExternalPrefixBlock
    array set BlockType {-Type -lsaType}
    set BlockTypeResult [lindex [GetAttributeList $sg_userLsa [array get BlockType]] 1]
    if {$BlockTypeResult=="asExternal"} {
        ixNet remove [lindex [ixNet getList $sg_userLsaGroup userLsa] $deleteid]
        ixNet commit
        set m_sg_userLsaGroup [lindex [ixNet remapIds $sg_userLsaGroup] 0]
    } else {
        puts "This is not External type RouteBlock,process stop"
        return $::FAILURE
    }
    
    #重建list
    set m_userLsaRouterName_List [lreplace $m_userLsaRouterName_List $deleteid $deleteid]           
    return $::SUCCESS
}    

#======================================================================
# 函数名称:ConfigTopExternalPrefixRouteBlock by sigma 2009.5.5
# 描述: 配置创建好的ExternalPrefixRouteBlock
# 参数:
# BlockName            要配置的Block标识 必选
# Metric               AS External的Metric字段
# Number               AS External的Number of LSA字段
# Prefix               AS External的address Prefix字段,IPv6形式 eg：2:2:2:2:2:2:2:2
# StartingAddress      AS External的LinkStateId字段,IPv4形式 eg：1.1.1.1
# Modifier             AS External的Increment ID字段,IPv4形式 eg：1.1.1.1
# FlagFbit             Fbit true or false
# FowardingAddress     AS External的FowardingAddress字段,IPv6形式 eg：2:2:2:2:2:2:2:2
# FlagASBR             ebit true or false
# AdvertisingRouterID  AS External的AdvertisingRouterID字段,IPv4形式 eg：1.1.1.1
# MetricType           AS External的 LS type字段：Ignore，routerLsa，Networklsa
# ExternalRouteTag     AS External的External Route Tag字段,IPv4形式 eg：1.1.1.1
# FlagTbit             Tbit true or false
# FlagNuBit            Nubit true or false
# FlagLaBit            Labit true or false
# FlagNssa             Pbit true or false
# 语法描述:
#    ospfv31 ConfigTopExternalPrefixRouteBlock -BlockName a -Numbner 10
# 返回值：
#    成功返回0
#=====================================================================
itcl::body OspfV3Router::ConfigTopExternalPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::ConfigTopExternalPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    #set args [ixConvertToLowerCase $args]
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    } 
    
    #检查BlockName是否存在
    if {[info exists args_array(-BlockName)] && \
        [lsearch $m_userLsaRouterName_List $args_array(-BlockName)] != -1} {
        set BlockNameId [lsearch $m_userLsaRouterName_List $args_array(-BlockName)]
    } else {
        puts "no this Blockname: $args_array(-BlockName) , process stop"
        return $::FAILURE
    }
    
    #没有routername，下面是定位到存在的最后一个router
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    if {$router_id == -1} {
        puts "no router exists, pls add router first"
    } else {
        set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    }
    
    #没有lsagroupname，定位到最后一个lsaGroup
    set lsaGroupId [expr ([llength [ixNet getList $sg_router userLsaGroup]]-1)]
    if {$lsaGroupId == -1} {
        puts "no router exists, pls add LsaGroup first"
    } else {
        set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId]
    }
    
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] $BlockNameId]
    set sg_asExternal $sg_userLsa/asExternal
    
    #判断是否是InterAreaPrefixBlock并修改需要的参数
    array set BlockRangeType {-blockType -lsaType}
    set BlockTypeResult [lindex [GetAttributeList $sg_userLsa [array get BlockRangeType]] 1]
    if {($BlockTypeResult=="asExternal")} {     
        if {[info exists args_array(-StartingAddress)]} {       
            set StartingAddress $args_array(-StartingAddress)
            ixNet setAttribute $sg_userLsa  -linkStateId  $StartingAddress
        }

        if {[info exists args_array(-Prefix)]} {
            set Prefix $args_array(-Prefix)
            ixNet setAttribute $sg_asExternal  -addPrefix $Prefix
        }

        if {[info exists args_array(-Number)]} {
            set Number $args_array(-Number)
            ixNet setAttribute $sg_asExternal  -lsaCount $Number
        }

        if {[info exists args_array(-Modifier)]} {
            set Modifier $args_array(-Modifier)
            ixNet setAttribute $sg_asExternal  -incrLinkStateId $Modifier
        }

        if {[info exists args_array(-FowardingAddress)]} {
            set FowardingAddress $args_array(-FowardingAddress)
            ixNet setAttribute $sg_asExternal  -forwardingAddress $FowardingAddress
        }
    
        if {[info exists args_array(-FlagFbit)] && \
            ([string match -nocase true $args_array(-FlagFbit)] || \
            [string match -nocase false $args_array(-FlagFbit)])} {
            set FlagFbit $args_array(-FlagFbit)
            ixNet setAttribute $sg_asExternal -fBit $FlagFbit
        }  
      
        if {[info exists args_array(-FlagLaBit)] && \
            ([string match -nocase true $args_array(-FlagLaBit)] || \
            [string match -nocase false $args_array(-FlagLaBit)])} {
            set FlagLaBit $args_array(-FlagLaBit)
            ixNet setAttribute $sg_asExternal -optBitLa $FlagLaBit
        }
       
        if {[info exists args_array(-FlagASBR)] && \
            ([string match -nocase true $args_array(-FlagASBR)] || \
            [string match -nocase false $args_array(-FlagASBR)])} {
            set FlagASBR $args_array(-FlagASBR)
            ixNet setAttribute $sg_asExternal -eBit $FlagASBR
        }

        if {[info exists args_array(-FlagTbit)] && \
            ([string match -nocase true $args_array(-FlagTbit)] || \
            [string match -nocase false $args_array(-FlagTbit)])} {
            set FlagTbit $args_array(-FlagTbit)
            ixNet setAttribute $sg_asExternal -tBit $FlagTbit
        }

        if {[info exists args_array(-FlagNuBit)] && \
            ([string match -nocase true $args_array(-FlagNuBit)] || \
            [string match -nocase false $args_array(-FlagNuBit)])} {
            set FlagNuBit $args_array(-FlagNuBit)
            ixNet setAttribute $sg_asExternal -optBitNu $FlagNuBit
        }

        if {[info exists args_array(-FlagNssa)] && \
            ([string match -nocase true $args_array(-FlagNssa)] || \
            [string match -nocase false $args_array(-FlagNssa)])} {
            set FlagNssa $args_array(-FlagNssa)
            ixNet setAttribute $sg_asExternal -optBitP $FlagNssa
        }

        if {[info exists args_array(-FlagTranslatePropagateType7)] && \
            ([string match -nocase true $args_array(-FlagTranslatePropagateType7)] || \
            [string match -nocase false $args_array(-FlagTranslatePropagateType7)])} {
            set FlagTranslatePropagateType7 $args_array(-FlagTranslatePropagateType7)
        
        }
       
        if {[info exists args_array(-ExternalRouteTag)]} {
            set ExternalRouteTag $args_array(-ExternalRouteTag)
            ixNet setAttribute $sg_asExternal  -externalRouteTag $ExternalRouteTag
        }

        if {[info exists args_array(-AdvertisingRouterID)]} {
            set AdvertisingRouterID $args_array(-AdvertisingRouterID)
            ixNet setAttribute $sg_userLsa  -advertisingRouterId  $AdvertisingRouterID
        }

        if {[info exists args_array(-MetricType)] && \
            ([string match -nocase ignore $args_array(-MetricType)] || \
            [string match -cocase networklsa $args_array(-MetricType)] || \
            [string match -nocase routerLsa $args_array(-MetricType)])} {
            set MetricType $args_array(-MetricType)
            ixNet setAttribute $sg_asExternal  -referenceLsType $MetricType
        }
    
        if {[info exists args_array(-Metric)] && \
            [string is integer $args_array(-Metric)]} {
            set Metric $args_array(-Metric)
            ixNet setAttribute $sg_asExternal  -metric $Metric
        }  
    } else {
        puts "It's not ExternalType Block,process stop"
    }
    ixNet commit
    set m_sg_asExternal [lindex [ixNet remapIds $sg_asExternal] 0]
    return $::SUCCESS    
}
   
#======================================================================
# 函数名称:GetTopExternalPrefixRouteBlock by sigma 2009.5.4
# 描述: 取得指定的ExternalPrefixRouteBlock参数,不接其他参数返回所有值
# 参数:
# BlockName            要获取的的Block标识  必选
# Metric               AS External的Metric字段
# Number               AS External的Number of LSA字段
# Prefix               AS External的address Prefix字段
# StartingAddress      AS External的LinkStateId字段
# Modifier             AS External的Increment ID字段
# FlagFbit             Fbit true or false
# FowardingAddress     AS External的FowardingAddress字段
# FlagASBR             ebit true or false
# AdvertisingRouterID  AS External的AdvertisingRouterID字段
# MetricType           AS External的 LS type字段：Ignore，routerLsa，Networklsa
# ExternalRouteTag     AS External的External Route Tag字段
# FlagTbit             Tbit true or false
# FlagNuBit            Nubit true or false
# FlagLaBit            Labit true or false
# FlagNssa             Pbit true or false
# 语法描述:
#   ospfv31 GetTopExternalPrefixRouteBlock -BlockName a -Metric -Number -Prefix
# 返回值：                                                          
#    返回相应列表
#=======================================================================
itcl::body OspfV3Router::GetTopExternalPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfRouter::GetTopExternalPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args_list $args
    #取得BlockName和后面的值
    set id [expr [lsearch $args_list "-BlockName"] + 1]
    set next [lindex $args_list $id]
    
    if {[lsearch $m_userLsaRouterName_List $next] == -1 || [lsearch $args_list "-BlockName"] == -1} {
        puts "need input BlockName or the BlockName not exist"
        return $::FAILURE
    } else {
        set BlockNameId [lsearch $m_userLsaRouterName_List $next]
    }
    
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    if {$router_id == -1} {
        puts "no router exists, pls add router first"
    } else {
        set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    }
       
    #没有lsagroupname，定位到最后一个lsaGroup
    set lsaGroupId [expr ([llength [ixNet getList $sg_router userLsaGroup]]-1)]
    if {$lsaGroupId == -1} {
        puts "no router exists, pls add LsaGroup first"
    } else {
        set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId]
    }

    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] $BlockNameId]
    set sg_asExternal $sg_userLsa/asExternal        
    array set ExternalBlock_list {-StartingAddress -linkStateId -Prefix -addPrefix \
        -AdvertisingRouterID -advertisingRouterId -Number -lsaCount  -Modifier \
        -incrLinkStateId -FlagFbit -fBit -FowardingAddress -forwardingAddress \
        -FlagASBR -eBit -MetricType -referenceLsType -Metric -metric -ExternalRouteTag \
        -externalRouteTag -FlagNuBit -optBitNu -FlagLaBit -optBitLa -FlagNssa \
        -optBitP -FlagTbit -tBit}
    
    array set ExternalBlock_list2 {-Prefix -addPrefix -Number -lsaCount  -Modifier \
        -incrLinkStateId -FlagFbit -fBit -FowardingAddress -forwardingAddress \
        -FlagASBR -eBit -MetricType -referenceLsType -Metric -metric -ExternalRouteTag \
        -externalRouteTag -FlagNuBit -optBitNu -FlagLaBit -optBitLa -FlagNssa \
        -optBitP -FlagTbit -tBit}
    
    #判断处理部分值还是全部值        
    if {[llength $args_list] >2} {
        #是否是asExternal Block  
        array set BlockRangeType {-blockType -lsaType}
        set BlockTypeResult [lindex [GetAttributeList $sg_userLsa [array get BlockRangeType]] 1]
        if {($BlockTypeResult=="asExternal")} {
            set flag 0
            foreach val $args_list { 
                #不处理BlockName参数
                if {$val== "-BlockName"} {
                    set id [expr [lsearch $args_list -BlockName] + 1]
                    set next [lindex $args_list $id]
                    incr flag
                    continue
                }
                #不处理BlockName的值    
                if {[info exists next] && ($val==$next)} {
                    incr flag
                    continue           
                }
                    
                if {$val == "-AdvertisingRouterID" || $val == "-StartingAddress"} {
                    set BlockResult [GetAttributeList $sg_userLsa [array get ExternalBlock_list $val]]
                    lappend results $BlockResult
                } else {
                    set BlockResult [GetAttributeList $sg_asExternal [array get ExternalBlock_list $val]]
                    lappend results $BlockResult
                }
            
                #不再次跳过与BlockName的值同名的参数                         
                if {($flag == 2) && ($val==$next)} {}          
            }
            puts $results
            return $::SUCCESS        
        } else {
            puts "It's not ExternalBlock"
            return $::FAILURE
        }    
    } else {
        set AdvRouterID [GetAttributeList $sg_userLsa [array get ExternalBlock_list -AdvertisingRouterID]]
        set StartAdd [GetAttributeList $sg_userLsa [array get ExternalBlock_list -StartingAddress]]
        set OtherResult [GetAttributeList $sg_asExternal [array get ExternalBlock_list2]]
        set results [concat $AdvRouterID $StartAdd $OtherResult]
        puts $results
        return $::SUCCESS
    }
}

#====================================================================
# 函数名称:#CreateTopInterAreaPrefixRouteBlock by sigma 2009.5.5
# 描述: 创建InterAreaPrefixRouteLsa的属性信息
# 参数:
# BlockName            创建Block标识 必选
# Metric               AS External的Metric字段
# Number               AS External的Number of LSA字段
# Prefix               AS External的address Prefix字段，IPv6形式 eg：1:1:1:1:1:1:1:1
# StartingAddress      AS External的LinkStateId字段，IPv4形式 eg：1.1.1.1
# Modifier             AS External的Increment ID字段，IPv4形式 eg：1.1.1.1
# AdvertisingRouterID  AS External的AdvertisingRouterID字段，IPv4形式 eg：1.1.1.1
# FlagNuBit            Nubit true or false
# FlagLaBit            Labit true or false
# FlagPbit             Pbit true or false
# 语法描述:
#    ospfv31 CreateTopInterAreaPrefixRouteBlock -BlockName a -Numbner 10
# 返回值：
#    成功返回0
#=======================================================================
itcl::body OspfV3Router::CreateTopInterAreaPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::CreateTopInterAreaPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    #set args [ixConvertToLowerCase $args]
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    } 
    
    if {![info exists args_array(-BlockName)]} {
        puts "CreateTopExternalPrefixRouteBlock need input BlockName!, process stop"
        return $::FAILURE
    } elseif {[lsearch $m_userLsaRouterName_List $args_array(-BlockName)]!=-1} {
        puts "This Name already exist! process stop"
        return $::FAILURE
    } else {
        lappend m_userLsaRouterName_List $args_array(-BlockName)
    }    

    if {![info exists args_array(-StartingAddress)]} {
        set StartingAddress 0.0.0.0
    } else {
        set StartingAddress $args_array(-StartingAddress)
    }

    if {![info exists args_array(-AdvertisingRouterID)]} {
        set AdvertisingRouterID 0.0.0.0
    } else {
        set AdvertisingRouterID $args_array(-AdvertisingRouterID)
    }
    
    if {![info exists args_array(-Prefix)]} {
        set Prefix 0:0:0:0:0:0:0:0
    } else {
        set Prefix $args_array(-Prefix)
    }

    if {![info exists args_array(-Number)]} {
        set Number 1
    } else {
        set Number $args_array(-Number)
    }

    if {![info exists args_array(-Modifier)]} {
        set Modifier 0.0.0.0
    } else {
        set Modifier $args_array(-Modifier)
    }

    if {![info exists args_array(-FlagPBit)] || \
        [string match -nocase true $args_array(-FlagPBit)]} {
        set FlagPBit false
    } else {
        set FlagPBit true
    }
      
    if {![info exists args_array(-FlagNuBit)] || \
        [string match -nocase true $args_array(-FlagNuBit)]} {
        set FlagNuBit false
    } else {
        set FlagNuBit true
    }

    if {![info exists args_array(-FlagLaBit)] || \
        [string match -nocase true $args_array(-FlagLaBit)]} {
        set FlagLaBit false
    } else {
        set FlagLaBit true
    }

    if {![info exists args_array(-Metric)] || \
        ![string is integer $args_array(-Metric)]} {
        set Metric 1
    } else {
        set Metric $args_array(-Metric)
    }
    
    #下面是定位到存在的最后一个router
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    if {$router_id == -1} {
        puts "no router exists, pls add router first"
    } else {
        set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    }
    
    set lsaGroupId [expr ([llength [ixNet getList $sg_router userLsaGroup]]-1)]
    if {$lsaGroupId == -1} {
        set sg_userLsaGroup [ixNet add $sg_router userLsaGroup]
    } else {
        set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId]
    }
    
    set sg_userLsa [ixNet add $sg_userLsaGroup userLsa]
    ixNet setAttribute $sg_userLsa  -advertisingRouterId  $AdvertisingRouterID
    ixNet setAttribute $sg_userLsa  -enabled true
    ixNet setAttribute $sg_userLsa  -linkStateId  $StartingAddress
    ixNet setAttribute $sg_userLsa  -lsaType interAreaPrefix
    ixNet commit
    
    set sg_interArea $sg_userLsa/interAreaPrefix
    ixNet setAttribute $sg_interArea  -addressPrefix  $Prefix
    ixNet setAttribute $sg_interArea  -lsaCount $Number
    ixNet setAttribute $sg_interArea  -incrLinkStateId $Modifier
    ixNet setAttribute $sg_interArea  -metric $Metric
    ixNet setAttribute $sg_interArea  -optBitNu $FlagNuBit
    ixNet setAttribute $sg_interArea  -optBitLa $FlagLaBit
    ixNet setAttribute $sg_interArea  -optBitP $FlagPBit
    ixNet commit
    set m_sg_interArea [lindex [ixNet remapIds $sg_interArea] 0]
    return $::SUCCESS    
}
#======================================================================
# 函数名称:DeleteTopInterAreaPrefixRouteBlock by sigma 2009.5.5
# 描述: 删除InterAreaBlock
# 参数:
# BlockName            要删除的Block标识 必选
# 语法描述:
#    ospfv31 DeleteTopInterAreaPrefixRouteBlock -BlockName a
#=======================================================================
itcl::body OspfV3Router::DeleteTopInterAreaPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::DeleteTopInterAreaPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    } 
 
    #检查BlockName是否存在
    if {[info exists args_array(-BlockName)] && \
        [lsearch $m_userLsaRouterName_List $args_array(-BlockName)] != -1} {
        set deleteid [lsearch $m_userLsaRouterName_List $args_array(-BlockName)]
    } else {
        puts "need input BlockName or BlockName not exist, process stop"
        return $::FAILURE
    }

    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId] 
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    set m_sg_router [lindex [ixNet remapIds $sg_router] 0] 
    set lsaGroupId [expr ([llength [ixNet getList $m_sg_router userLsaGroup]]-1)]
    set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId] 
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] $deleteid] 
    #判断删除的是否为InterAreaPrefix
    array set BlockType {-Type -lsaType}
    set BlockTypeResult [lindex [GetAttributeList $sg_userLsa [array get BlockType]] 1]
    if {$BlockTypeResult=="interAreaPrefix"} {
        ixNet remove [lindex [ixNet getList $sg_userLsaGroup userLsa] $deleteid]
        ixNet commit
        set m_sg_userLsaGroup [lindex [ixNet remapIds $sg_userLsaGroup] 0]
    } else {
        puts "This is not InterAreaPrefix type Block,process stop"
        return $::FAILURE
    }
    
    #重建List
    set m_userLsaRouterName_List [lreplace $m_userLsaRouterName_List $deleteid $deleteid]         
    return $::SUCCESS
}    

#=================================================================
# 函数名称:ConfigTopInterAreaPrefixRouteBlock by sigma 2009.5.5
# 描述: 配置InterAreaPrefixRouteLsa的属性信息
# 参数:
# BlockName            要配置的Block标识 必选
# Metric               AS External的Metric字段
# Number               AS External的Number of LSA字段
# Prefix               AS External的address Prefix字段,IPv6地址，eg：2:2:2:2:2:2:2:2
# StartingAddress      AS External的LinkStateId字段，IPv4形式 eg：1.1.1.1
# Modifier             AS External的Increment ID字段，IPv4形式 eg：1.1.1.1
# AdvertisingRouterID  AS External的AdvertisingRouterID字段,IPv4形式 eg：1.1.1.1
# FlagNuBit            Nubit true or false
# FlagLaBit            Labit true or false
# FlagPbit             Pbit true or false
# 语法描述:
#    ospfv31 ConfigTopInterAreaPrefixRouteBlock -BlockName a -Numbner 10
# 返回值：
#    成功返回0
#======================================================================
itcl::body OspfV3Router::ConfigTopInterAreaPrefixRouteBlock {args} {
    ixDebugPuts "Enter proc OspfV3Router::ConfigTopInterAreaPrefixRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    #set args [ixConvertToLowerCase $args]
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    } 
    
    #检查BlockName是否存在
    if {[info exists args_array(-BlockName)] && \
        [lsearch $m_userLsaRouterName_List $args_array(-BlockName)] != -1} {
        set BlockNameId [lsearch $m_userLsaRouterName_List $args_array(-BlockName)]
    } else {
        puts "Need input BlockName or BlockName not exist, process stop"
        return $::FAILURE
    }
    
    #没有routername，下面是定位到存在的最后一个router
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    if {$router_id == -1} {
        puts "no router exists, pls add router first"
    } else {
        set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    }
    
    #没有lsagroupname，定位到最后一个lsaGroup
    set lsaGroupId [expr ([llength [ixNet getList $sg_router userLsaGroup]]-1)]
    if {$lsaGroupId == -1} {
        puts "no LsaGroup exists, pls add LsaGroup first"
    } else {
        set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId]
    }
    
    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] $BlockNameId]
    set sg_interArea $sg_userLsa/interAreaPrefix
    
    #判断是否是InterAreaPrefixBlock并修改需要的参数
    array set BlockRangeType {-blockType -lsaType}
    set BlockTypeResult [lindex [GetAttributeList $sg_userLsa [array get BlockRangeType]] 1]
    if {($BlockTypeResult=="interAreaPrefix")} {        
        if {[info exists args_array(-StartingAddress)]} {       
            set StartingAddress $args_array(-StartingAddress)
            ixNet setAttribute $sg_userLsa  -linkStateId  $StartingAddress
        }

        if {[info exists args_array(-Prefix)]} {
            set Prefix $args_array(-Prefix)
            ixNet setAttribute $sg_interArea  -addressPrefix  $Prefix
        }

        if {[info exists args_array(-Number)]} {
            set Number $args_array(-Number)
            ixNet setAttribute $sg_interArea -lsaCount $Number
        }

        if {[info exists args_array(-Modifier)]} {
            set Modifier $args_array(-Modifier)
            ixNet setAttribute $sg_interArea -incrLinkStateId $Modifier
        }

        if {[info exists args_array(-FowardingAddress)]} {
            set FowardingAddress $args_array(-FowardingAddress)
            ixNet setAttribute $sg_interArea -forwardingAddress $FowardingAddress
        } 
      
        if {[info exists args_array(-FlagLaBit)] && \
            ([string match -nocase true $args_array(-FlagLaBit)] || \
            [string match -nocase false $args_array(-FlagLaBit)])} {
            set FlagLaBit $args_array(-FlagLaBit)
            ixNet setAttribute $sg_interArea -optBitLa $FlagLaBit
          }

        if {[info exists args_array(-FlagPBit)] && \
            ([string match -nocase true $args_array(-FlagPBit)] || \
            [string match -nocase false $args_array(-FlagPBit)])} {
            set FlagPBit $args_array(-FlagPBit)
            ixNet setAttribute $sg_interArea -optBitP $FlagPBit
        }
    
       if {[info exists args_array(-FlagNuBit)] && \
            ([string match -nocase true $args_array(-FlagNuBit)] || \
            [string match -nocase false $args_array(-FlagNuBit)])} {
            set FlagNuBit $args_array(-FlagNuBit)
            ixNet setAttribute $sg_interArea -optBitNu $FlagNuBit
        }

        if {[info exists args_array(-AdvertisingRouterID)]} {
            set AdvertisingRouterID $args_array(-AdvertisingRouterID)
            ixNet setAttribute $sg_userLsa -advertisingRouterId $AdvertisingRouterID
        }

        if {[info exists args_array(-Metric)] && \
            [string is integer $args_array(-Metric)]} {
            set Metric $args_array(-Metric)
            ixNet setAttribute $sg_interArea -metric $Metric
        }  
    } else {
        puts "It's not interArea Type Block, process stop"
    }
    ixNet commit
    set m_sg_interArea [lindex [ixNet remapIds $sg_interArea] 0]
    return $::SUCCESS    
}
   
#======================================================================
# 函数名称:GetTopInterAreaPrefixlRouteBlock by sigma 2009.5.5
# 描述: 获取Block里指定的参数值,不接其他参数返回所有值
# 参数:
# BlockName            要配置的Block标识 必选
# Metric               AS External的Metric字段
# Number               AS External的Number of LSA字段
# Prefix               AS External的address Prefix字段
# StartingAddress      AS External的LinkStateId字段
# Modifier             AS External的Increment ID字段
# AdvertisingRouterID  AS External的AdvertisingRouterID字段
# FlagNuBit            Nubit true or false
# FlagLaBit            Labit true or false
# FlagPbit             Pbit true or false
# 语法描述:
#    ospfv31 GetTopInterAreaPrefixlRouteBlock -BlockName a -Numbner -Modifier
# 返回值：
#    返回相应列表
#=======================================================================
itcl::body OspfV3Router::GetTopInterAreaPrefixlRouteBlock {args} {
    ixDebugPuts "Enter proc OspfRouter::GetTopInterAreaPrefixlRouteBlock...\n"
    set procname [lindex [info level [info level]] 0]
    set args_list $args
    #取得BlockName和后面的值
    set id [expr [lsearch $args_list "-BlockName"] + 1]
    set next [lindex $args_list $id]
    
    if {[lsearch $m_userLsaRouterName_List $next] == -1 || [lsearch $args_list "-BlockName"] == -1} {
        puts "need input BlockName or the BlockName not exist"
        return $::FAILURE
    } else {
        set BlockNameId [lsearch $m_userLsaRouterName_List $next]
    }
    
    set vport [$IxiaCapi::namespaceArray($m_portObjectId,namespace)::$m_portObjectId cget -m_vportId]
    set router_id [expr ([llength [ixNet getList $vport/protocols/ospfV3 router]]-1)]
    if {$router_id == -1} {
        puts "no router exists, pls add router first"
    } else {
        set sg_router [lindex [ixNet getList $vport/protocols/ospfV3 router] $router_id]   
    }
       
    #没有lsagroupname，定位到最后一个lsaGroup
    set lsaGroupId [expr ([llength [ixNet getList $sg_router userLsaGroup]]-1)]
    if {$lsaGroupId == -1} {
        puts "no router exists, pls add LsaGroup first"
    } else {
        set sg_userLsaGroup [lindex [ixNet getList $sg_router userLsaGroup] $lsaGroupId]
    }

    set sg_userLsa [lindex [ixNet getList $sg_userLsaGroup userLsa] $BlockNameId]
    set sg_asExternal $sg_userLsa/interAreaPrefix        
    array set interAreaPrefix_list {-StartingAddress -linkStateId -AdvertisingRouterID \
        -advertisingRouterId -Prefix -addressPrefix  -Number -lsaCount -Modifier -incrLinkStateId \
        -Metric -metric -FlagNuBit -optBitNu -FlagLaBit -optBitLa -FlagPBit -optBitP}
    
    array set interAreaPrefix_list2 {-Prefix -addressPrefix -Number -lsaCount -Modifier \
        -incrLinkStateId -Metric -metric -FlagNuBit -optBitNu -FlagLaBit -optBitLa \
        -FlagPBit -optBitP}
    
    #判断处理部分值还是全部值        
    if {[llength $args_list] >2} {
        #是否是SummaryRouteBlock    
        array set BlockRangeType {-blockType -lsaType}
        set BlockTypeResult [lindex [GetAttributeList $sg_userLsa [array get BlockRangeType]] 1]
        if {($BlockTypeResult=="interAreaPrefix")} {
            set flag 0
            foreach val $args_list { 
                #不处理BlockName
                if {$val== "-BlockName"} {
                    set id [expr [lsearch $args_list -BlockName] + 1]
                    set next [lindex $args_list $id]
                    incr flag
                    continue
                }
                #不处理BlockName的值    
                if {[info exists next] && ($val==$next)} {
                    incr flag
                    continue           
                }
                    
                if {$val == "-AdvertisingRouterID" || $val == "-StartingAddress"} {
                    set BlockResult [GetAttributeList $sg_userLsa [array get interAreaPrefix_list $val]]
                    lappend results $BlockResult
                } else {
                    set BlockResult [GetAttributeList $sg_asExternal [array get interAreaPrefix_list $val]]
                    lappend results $BlockResult
                }
            
                #不再次跳过与BlockName的值同名的参数                         
                if {($flag == 2) && ($val==$next)} {}          
            }
            puts $results
            return $::SUCCESS        
        } else {
            puts "It's not InterAreaPrefixBlock"
            return $::FAILURE
        }    
    } else {
        set AdvRouterID [GetAttributeList $sg_userLsa [array get interAreaPrefix_list -AdvertisingRouterID]]
        set StartAdd [GetAttributeList $sg_userLsa [array get interAreaPrefix_list -StartingAddress]]
        set OtherResult [GetAttributeList $sg_asExternal [array get interAreaPrefix_list2]]
        set results [concat $AdvRouterID $StartAdd $OtherResult]
        puts $results
        return $::SUCCESS
    }
}
#============================
itcl::body OspfV3Router::GetRouterStats {args} {

    ixDebugPuts "Enter proc IsisRouter::GetRouterStats...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    #这里是读入所有的args的名称,然后打印每个args的实际的值.
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
    puts "Current page is : $Curpage"
    puts "Current page is : $ProtoStats"

    set row [lindex [ixNet getList $ProtoStats row] 0]
    
    for {set i 0} {$i<100} {incr i} {    
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
             -NumHelloReceived {
                set MyObj [lindex [ixNet getList $row cell] 11]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig                
             }
             -NumDbdReceived        {
                set MyObj [lindex [ixNet getList $row cell] 13]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig 
             }
             -NumRtrLsaReceived      {
                set MyObj [lindex [ixNet getList $row cell] 23]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig 
             }
             -NumNetLsaReceived {
                set MyObj [lindex [ixNet getList $row cell] 27]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             } 
             -NumSum4LsaReceived {
                set MyObj [lindex [ixNet getList $row cell] 33]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumSum3LsaReceived {
                set MyObj [lindex [ixNet getList $row cell] 31]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumExtLsaReceived {
                set MyObj [lindex [ixNet getList $row cell] 35]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumOpq9LsaReceived {
                set MyObj [lindex [ixNet getList $row cell] 30]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumOtherLsaReceived {
                set MyObj [lindex [ixNet getList $row cell] 20]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumHelloSent {
                set MyObj [lindex [ixNet getList $row cell] 10]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumDbdSent {
                set MyObj [lindex [ixNet getList $row cell] 12]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
                }
             -NumRtrLsaSent {
                set MyObj [lindex [ixNet getList $row cell] 22]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             }
             -NumNetLsaSent {
                set MyObj [lindex [ixNet getList $row cell] 26]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             }
             -NumSum4LsaSent {
                set MyObj [lindex [ixNet getList $row cell] 32]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             }
             -NumSum3LsaSent {
                set MyObj [lindex [ixNet getList $row cell] 30]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             }
             -NumExtLsaSent {
                set MyObj [lindex [ixNet getList $row cell] 34]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             }
             -NumOpq9LsaSent  {
                set MyObj [lindex [ixNet getList $row cell] 28]  
                set SConfig [ixNet getAttr $MyObj -statValue]
                upvar $value arg
                set arg $SConfig
             }
             -NumOtherLsaSent {
                set MyObj [lindex [ixNet getList $row cell] 20]  
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
}

