#====================================================================
# 版本号：1.0
#   
# 文件名：Ixia_CIsisRouter.tcl
# 
# 文件描述：IxiaCapi库中ISIS路由类
# 
# 作者：Roger Yang
#
# 创建时间: 2009.03.05
#
# 修改记录： 
#   
# 版权所有：Ixia
#====================================================================

#====================================================================
# 类名称:                                                           
#    ::IsisRouter    By Roger Yang                                           
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

        #这里是获取 vport/Interface的对象,这个Interface在很多地方需要用到,比如指定路由器使用哪个Interface.一个
        #接口上可以建立多个Interfaces,所以还需要参考Shawn的代码进行修改.
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
    
    ;#以下声明要实现的方法,即具体的API.
    public method ConfigRouter
    public method GetRouter
    public method Enable
    public method Disable
    public method AddGrid
    public method ConfigGrid
    public method RemoveGrid
    
    #以下8个函数为第一次现场验收后根据ZTE要求新增的函数
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
    public method AdvertiseRouters  ;# 这个函数Ixia不支持
    public method WithdrawRouters   ;# 这个函数Ixia不支持
    public method StartISISRouter ;# 这个函数非CAPI函数,是Roger自己定制作为Debug所用.
    public method StopISISRouter  ;# 这个函数非CAPI函数,是Roger自己定制作为Debug所用.
}

#PASS
#====================================================================
# 函数名称:ConfigRouter by Roger 2009.3
# 函数编写: 杨卓 
# 功能描述:创建Isis Router
#
# 输入参数:
# 参数名称              参数说明                参数类型       Ixia支持
#AddressFamily	        IPv4 ，IPV6 ， both	可选           支持
# 以下4个变量重新启用,因为在本函数中需要使用IP地址来判断使用哪一个接口.
#IpV4Addr	        Isis Router的IP地址。 	可选           支持
#IpV4PrefixLen	        IP地址的前缀长度                       支持
#IPV6Addr	        Isis Router的Ipv6地址	可选           支持
#IpV6PrefixLen	        IP地址的前缀长度	可选           支持
#AreaId	                区域ID	    可选                       支持
#                       举例: "49 00 01" 要带引号.
#SystemId	        系统ID	                可选           支持
#                       举例: "5E 1C 00 01 00 00" 要带引号
#RouterId	        流量工程routerID	可选           支持
#FlagWideMetric 	是否支持宽度量	可选                   支持,在TE选项中.
#FlagThree-wayHandshake	是否支持Three-way握手	可选           
#FlagRestartHelper 	是否支持GRHelper	可选           支持,在HitlessRestart中.
#                       举例: True/false     
#FlagDropSutLsp	        是否丢弃所有来自SUT发来的LSP	可选   支持,
#FlagMultiTopology	是否支持多拓扑	可选                   不支持 
#HoldTimer	        邻居保持时间	可选                   支持
#IihInterval	        IIH的发送时间间隔,就是Hello报文间隔	可选      支持
#CsnpInterval	        CSNP的发送时间间隔	可选           不支持
#PsnpInterval	        PSNP的发送时间间隔	可选           不支持
#MaxPacketSize	        数据包最大长度	可选                    支持, 即Max LSP Size, 在general设置中,最大1497
#L2RouterPriority	L2路由器的优先级	可选            暂不支持 只读 在Interfaces下的Advanced Interfaces settings
#L1RouterPriority	L1路由器的优先级	可选            暂不支持 只读
#RoutingLevel	        路由器的层次	可选                    支持   这个就是is-type
##                      举例: 1 , 2 , 1+2 即level1 , level2, level1+2
#AreaId1 	        区域ID	可选                            有疑问 即Area Address,在Advanced Routing Settings中的 Area选项.
#AreaId2	        区域ID	可选                            有疑问
#Active	                该协议仿真功能enable or disable	可选    支持
#                        根据要求,所有Router默认状态都必须是Disable的,如果要启用,则必须使用Enable函数,所以在用户
#                       ConfigRouter的时候无论他输入的是Enable还是Disable,这里都是Disable.
#GRT1Interval        	GR所需T1的时间	可选                    不支持
#GRT2Interval	        GR所需T2的时间	可选                    不支持
#GRT3Interval	        GR所需T3的时间	可选                    不支持
#LevelGRT1	        GR T1所在层次	可选                    不支持
#LevelGRT2	        GR T2所在层次	可选                    不支持
#LevelGRT3	        GR T3所在层次	可选                    不支持
#AuthType	        认证类型。其四个枚举类型置如下： (1)NO_AUTHENTICATION (2)LINK_AUTHENTICATION (3)AREA_AUTHENTICATION
#                       (4)DOMAIN_AUTHENTICATION	可选    支持, LINK_AUTHENTICATION就是Ixia的接口下的Circuit Authentication.
#FlagL1IIHAuth	        层1IIH报文认证	可选                     
#FlagL2IIHAuth	        层2IIH报文认证	可选
#FlagL1LSPAuth	        层1LSP报文认证	可选
#FlagL2LSPAuth	        层2LSP报文认证	可选
#FlagSNPAuth	        SNP报文认证	可选
#FlagGatewayAdd	        是否支持网关	可选
#FlagTE	                增加 FlagTe参数。在默认情况下，应该是不能启用TE功能的，因为TE功能只在Metric类型为wide时才生效	可选
#		        可选   支持
#                        举例: True/False
#
#Metric	                接口的cost值与FlagWideMetric 值相关 	可选  支持, 即IxN下的Interface Metric
#                       举例: 10
#AuthPassword	        ISIS 的实例中认证	可选
#AuthPasswordIIh	ISIS hello报文认证	可选
#
#
# 语法描述:                                                         
#    IsisRouter ConfigRouter –IpAddr 192.1.1.2 –PrefixLen 24 –AreaID 00 –SysID aaaaaaaaaaaa –Level L1                                    
# 返回值：                                                          
#    成功0，失败1；                         
#====================================================================
itcl::body IsisRouter::ConfigRouter {args} {
        
    ixDebugPuts "Enter proc IsisRouter::ConfigRouter...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set addressFamily "ipv4"
    set ipv4Addr "20.3.17.2"
    set flagWideMetric "False"
    set holdTimer 0
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]


#以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
    #根据要求,所有Router默认状态都必须是Disable的,如果要启用,则必须使用Enable函数,所以在用户
    #ConfigRouter的时候无论他输入的是Enable还是Disable,这里都是Disable.
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

    
    
    #下面这一段是为ISIS创建一个路由接口,并把这个路由接口对应到已经创建实际的IP Interfaces上去.
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
    ##这里需要根据用户输入的IPv4/v6的地址来判断使用哪一个Interface.
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
    
    
    ;#如果用户选择使用IPv4的接口,则必须把IPv6的接口信息删除.因为在创建HOST的时候,同时会创建IPv6和v4的接口信息
    ;# 而当用户选择IPv6的接口来使用,则Ixia会自动选择IPv6,就不用删除IPv4的接口了.
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
# 函数名称:GetRouter
# 函数编写: 杨卓 2009.4.20
# 功能描述: 获取Isis Router的配置信息, 根据用户的输入打印每个可选参数的实际的值.
#
# 输入参数:
# 参数名称              参数说明                参数类型       Ixia支持
#AddressFamily	        IPv4 ，IPV6 ， both	可选           支持
# 以下4个变量取消,因为在CreateHost中已经创建了接口了.
#IpV4Addr	        Isis Router的IP地址。 	可选           支持  
#IpV4PrefixLen	        IP地址的前缀长度                       支持
#IPV6Addr	        Isis Router的Ipv6地址	可选           支持
#IpV6PrefixLen	        IP地址的前缀长度	可选           支持
#AreaId	                区域ID	    可选                       支持
#                       举例: "49 00 01" 要带引号.
#SystemId	        系统ID	                可选           支持
#                       举例: "5E 1C 00 01 00 00" 要带引号
#RouterId	        流量工程routerID	可选           支持
#FlagWideMetric 	是否支持宽度量	可选                   支持,在TE选项中.
#FlagThree-wayHandshake	是否支持Three-way握手	可选           
#FlagRestartHelper 	是否支持GRHelper	可选           支持,在HitlessRestart中.
#                       举例: True/false     
#FlagDropSutLsp	        是否丢弃所有来自SUT发来的LSP	可选   支持,
#FlagMultiTopology	是否支持多拓扑	可选                   不支持 
#HoldTimer	        邻居保持时间	可选                   支持
#IihInterval	        IIH的发送时间间隔,就是Hello报文间隔	可选      支持
#CsnpInterval	        CSNP的发送时间间隔	可选           不支持
#PsnpInterval	        PSNP的发送时间间隔	可选           不支持
#MaxPacketSize	        数据包最大长度	可选                    支持, 即Max LSP Size, 在general设置中,最大1497
#L2RouterPriority	L2路由器的优先级	可选            暂不支持 只读 在Interfaces下的Advanced Interfaces settings
#L1RouterPriority	L1路由器的优先级	可选            暂不支持 只读
#RoutingLevel	        路由器的层次	可选                    支持   这个就是is-type
##                      举例: 1 , 2 , 1+2 即level1 , level2, level1+2
#AreaId1 	        区域ID	可选                            有疑问 即Area Address,在Advanced Routing Settings中的 Area选项.
#AreaId2	        区域ID	可选                            有疑问
#Active	                该协议仿真功能enable or disable	可选    支持
#GRT1Interval        	GR所需T1的时间	可选                    不支持
#GRT2Interval	        GR所需T2的时间	可选                    不支持
#GRT3Interval	        GR所需T3的时间	可选                    不支持
#LevelGRT1	        GR T1所在层次	可选                    不支持
#LevelGRT2	        GR T2所在层次	可选                    不支持
#LevelGRT3	        GR T3所在层次	可选                    不支持
#AuthType	        认证类型。其四个枚举类型置如下： (1)NO_AUTHENTICATION (2)LINK_AUTHENTICATION (3)AREA_AUTHENTICATION
#                       (4)DOMAIN_AUTHENTICATION	可选    支持, LINK_AUTHENTICATION就是Ixia的接口下的Circuit Authentication.
#FlagL1IIHAuth	        层1IIH报文认证	可选                     
#FlagL2IIHAuth	        层2IIH报文认证	可选
#FlagL1LSPAuth	        层1LSP报文认证	可选
#FlagL2LSPAuth	        层2LSP报文认证	可选
#FlagSNPAuth	        SNP报文认证	可选
#FlagGatewayAdd	        是否支持网关	可选
#FlagTE	                增加 FlagTe参数。在默认情况下，应该是不能启用TE功能的，因为TE功能只在Metric类型为wide时才生效	可选
#		        可选   支持
#                        举例: True/False
#
#Metric	                接口的cost值与FlagWideMetric 值相关 	可选  支持, 即IxN下的Interface Metric
#                       举例: 10
#AuthPassword	        ISIS 的实例中认证	可选
#AuthPasswordIIh	ISIS hello报文认证	可选
#
#
# 语法描述:                                                         
#    isis1 GetRouter -addressfamily  IPv4 -areaid "00 00 01" -systemid "64 01 00 01 00 00"
#                                      
# 返回值：                                                          
#    打印每个可选参数的值,如本例中应该打印
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
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    #这里是读入所有的args的名称,然后打印每个args的实际的值.
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
# 函数名称: Enable  
# 函数编写: 杨卓  Roger 2009.3.23
# 描述: 使能指定的 ISIS Router
# 参数: 
#
# 语法描述:                                                         
#
#   isis1 Enable
#
# 返回值：  无
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
# 函数名称:Disable
# 函数编写: 杨卓  2009.3.23
# 功能描述: 禁用指定的ISIS Router
# 输入参数:
# 语法描述:                                                         
#      isis Disable
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::Disable {args} {
    ixDebugPuts "Enter proc IsisRouter::Disable...\n"
    ixNet setAttribute $m_ixRouterId -enabled False
    ixNet commit
    set m_ixRouterId [ixNet remapIds $m_ixRouterId]
    return $::SUCCESS 
}



#通过 2008-4-17
#====================================================================
# 函数名称:AddGrid
# 函数编写: 杨卓 2009.3.24
# 功能描述: 为指定的ISIS Router创建ISIS网格拓扑；
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# GridName	ISIS Grid的名称标识，            必选                  支持
#                要求每ISIS邻居唯一。 	         必选	     无        不支持
# GridRows	模拟的ISIS Grid的行数。	         可选	     1         支持
# GridCols	模拟的ISIS Grid的列数。	         可选	     1         支持
# StartingRouterId	最开始的RouterID号	 	               支持
#                    举例: {99 00 00 00 00 00 } 或者 "99 00 00 00 00 00"
# StartingSystemId	最开始的SystemID号		               不支持
# FlagAdvetisted	广播方式(即是否广播)		                支持
# FlagTe	支持流量工程		                               支持
# MultiTopology	支持多拓扑		                               支持 
# RoutingLevel	路由器层次		                               ?是否要IsType还是什么意思?
# AddressFamily	 Ixia猜测:应该是广播的路由的类型IPv4或v6.               支持	
#                举例: ipv4, ipv6
# Ixia建议增加以下参数:
# StartIP        这个参数是Grid中第一个IP地址. 默认: 200.1.1.1
# StartIPMask    这个参数是Grid中第一个IP地址的掩码长度, 默认: 24
# 语法描述:                                                         
#      isis AddGrid 
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::AddGrid {args} {
    ixDebugPuts "Enter proc IsisRouter::AddGrid...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set gridName grid1
    set flagAdvetisted "false"
    set gridRows 1
    set gridCols 1
    set startIp 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称:ConfigGrid  
# 函数编写: 杨卓 2009.3.30
# 功能描述: 为指定的ISIS Router  修改已经存在的ISIS网格拓扑；
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# GridName	ISIS Grid的名称标识，
#                要求每ISIS邻居唯一。 	         必选	     无        不支持
# GridRows	模拟的ISIS Grid的行数。	         可选	     1         支持
# GridCols	模拟的ISIS Grid的列数。	         可选	     1         支持
# StartingRouterId	最开始的RouterID号	 	               支持
#                    举例: {99 00 00 00 00 00 } 或者 "99 00 00 00 00 00"
# StartingSystemId	最开始的SystemID号		               不支持
# FlagAdvetisted	广播方式(即是否广播)	 	                支持       
# FlagTe	支持流量工程		                               支持
# MultiTopology	支持多拓扑		                               支持 
# RoutingLevel	路由器层次		                               ?是否要IsType还是什么意思?
# AddressFamily	 Ixia猜测:应该是广播的路由的类型IPv4或v6.               支持	
#                举例: ipv4, ipv6
# Ixia建议增加以下参数:
# StartIP        这个参数是Grid中第一个IP地址. 默认: 200.1.1.1
# StartIPMask    这个参数是Grid中第一个IP地址的掩码长度, 默认: 24
# 语法描述:                                                         
#      isis1 ConfigGrid -gridname "grid1" -flagadvetisted "true" -gridcols 3 -gridrows 3 -startingrouterid {00 00 00 88 88 00} -startip 188.1.1.1 -startIpMask 16 \
#                       -addressFamily IPV4  -flagte "false"   
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::ConfigGrid {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigGrid...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set gridname ""
    set flagAdvetisted "false"
    set gridRows 1
    set gridCols 1
    set startIp 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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


#通过
#====================================================================
# 函数名称:RemoveGrid  
# 函数编写: 杨卓 2009.4.16
# 功能描述: 删除指定ISIS Router的ISIS Grid；
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# GridName	ISIS Grid的名称标识，             必选                 支持
# 语法描述:                                                         
#      isis RemoveGrid -gridname grid1 
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::RemoveGrid {args} {
    ixDebugPuts "Enter proc IsisRouter::RemoveGrid...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set gridname ""
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称: AddTopRouter  
# 函数编写: 杨卓 2009.6
# 功能描述: 为指定的ISIS Router创建ISIS网格拓扑； Ixia补充说明, 这里就是创建一个1*1的逻辑NetworkRange.
#           在后面要使用ConfigTopRouter进行配置, 然后要使用AddTopRouterLink以及ConfigTopRouterLink把这个NetworkRange
#           和一个具体的仿真路由接口进行连接. 所以这个函数的作用仅仅就是接收用户参数输入,保存到一个数组中,
#           在使用ddTopRouterLink以及ConfigTopRouterLink的时候读入这些参数来创建真实的NetworkRange.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
#
# RouterName	     ISIS Router的名称标识，                            
#                    要求每ISIS邻居唯一。 	必选	      无        支持            
# SystemID	    ISIS Router的SystemID	 可选	      1         不支持  
# RoutingId		                          可选	      1         支持
# PseudonodeNumber	伪节点号。只支持两个16进制数的形式 		不支持
# RoutingLevel	       路由器层次		                        
# FlagTe	      流量工程		                                支持
# FlagTag	        标签	                 可选	                不支持
# FlagMultiTopology	多拓扑		                                不支持
# FlagAdvertise  	通告方式,enable/disable                         支持
# AddressFamily	         IPV4 IPV6 Both		                        支持
# FlagAttachedBit	与其他区域相连		                        不支持
# FlagOverLoadBit	超载		                                不支持
# AreaId	        区域ID		                                 不支持
# 			
# AreaId1			
# AreaId2			
#
# 语法描述:                                                         
#      isis AddTopRouter -routername toprouter1 -routingid "00 00 00 00 00 00" 
#      
# 返回值：                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::AddTopRouter {args} {
    ixDebugPuts "Enter proc IsisRouter::AddTopRouter...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routerName     toprouter1
    set routingId      {00 00 00 88 88 00}
    set flagAdvertise  "enable"

    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称: ConfigTopRouter  
# 函数编写: 杨卓 2009.6
# 功能描述: 为指定的ISIS Router创建ISIS网格拓扑； Ixia补充说明, 这里就是根据已经创建的NetworkRange来修改它的参数
#           然后要使用AddTopRouterLink以及ConfigTopRouterLink把这个NetworkRange
#           和一个具体的仿真路由接口进行连接. 所以这个函数的作用仅仅就是接收用户参数输入,保存到一个数组中,
#           在使用ddTopRouterLink以及ConfigTopRouterLink的时候读入这些参数来创建真实的NetworkRange.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
#
# RouterName	     ISIS Router的名称标识，                            
#                    要求每ISIS邻居唯一。 	必选	      无        支持            
# SystemID	    ISIS Router的SystemID	 可选	      1         不支持  
# RoutingId		                          可选	      1         支持
# PseudonodeNumber	伪节点号。只支持两个16进制数的形式 		不支持
# RoutingLevel	       路由器层次		                        
# FlagTe	      流量工程		                                支持
# FlagTag	        标签	                 可选	                不支持
# FlagMultiTopology	多拓扑		                                不支持
# FlagAdvertise  	通告方式,enable/disable                         支持
# AddressFamily	         IPV4 IPV6 Both		                        支持
# FlagAttachedBit	与其他区域相连		                        不支持
# FlagOverLoadBit	超载		                                不支持
# AreaId	        区域ID		                                 不支持
# 			
# AreaId1			
# AreaId2			
#
# 语法描述:                                                         
#      isis ConfigTopRouter -routername toprouter1 -routingid "00 00 00 00 00 00" 
#      
# 返回值：                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::ConfigTopRouter {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigTopRouter...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routerName     toprouter1
    set routingId      {00 00 00 88 88 00}
    set flagAdvertise  "enable"

    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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





#通过! 2009.7.23
#====================================================================
# 函数名称:AddTopRouterLink
# 函数编写: 杨卓 2009.6
# 功能描述:  为指定的ISIS Router创建ISIS网格拓扑；
# Ixia解释: 根据已经创建的TopRouter,(即NetworkRange的参数),来讲逻辑的1*1的NetworkRange挂到指定的仿真路由
#           接口之下.其实这个函数做的事情就是在已经存在的一个ISIS Router接口下创建一个NetworkRange,而这个NetworkRange
#           的参数值由前面设置的TopRouter的参数值而来.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# RouterName	 这个是仿真接口Router的名称标识           必选	      无        支持
# Ipv4Address    这个是仿真接口的IP地址       可选	      无        支持                 
# Ipv6Address	这个1*1的First RouteIPv6地址      可选	      无        支持 
# ConnectedName	 这个是TopRouter或TopNetwork的名称                                无        支持		
# NeiIpv4Address	这个是TopRouter或TopNetwork的IP		              无        支持
# NeiIpv6Address	邻居ipv6地址		                        不支持
# FlagTe	流量工程 		                                不支持
# FlagTag	标签	可选	                                        不支持
# FlagAdvertise	通告方式		                                支持    
# NarrowMetric	窄度量		                                        不支持
# WideMetric	宽度量	enable/diasble                                  支持
# MaxBandwith	最大带宽		                                不支持
# ReservableBandwith	预留带宽		                        不支持
# AdminGroup	管理组		                                        不支持
# UnreservedBw	无限制带宽		                                不支持
# LinkName	邻接名称		                                支持
#
# 语法描述:                                                         
#      isis AddTopRouterLink -routername toprouter1 -ipv4address 200.1.1.1 -neiipv4address 20.3.17.2 \
                             -flagadvertise enable
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::AddTopRouterLink {args} {
    ixDebugPuts "Enter proc IsisRouter::AddTopRouterLink...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  

    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routerName toprouter1
    set flagAdvetisted "enable"
    set gridRows 1
    set gridCols 1
    set ipv4Address 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    set wideMetric "disable"

    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]


    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称:ConfigTopRouterLink
# 函数编写: 杨卓 2009.6
# 功能描述:  为指定的ISIS Router创建ISIS网格拓扑；
# Ixia解释: 根据已经创建的TopRouter,(即NetworkRange的参数),来讲逻辑的1*1的NetworkRange挂到指定的仿真路由
#           接口之下.其实这个函数做的事情就是在已经存在的一个ISIS Router接口下创建一个NetworkRange,而这个NetworkRange
#           的参数值由前面设置的TopRouter的参数值而来.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持         
# RouterName	 这个是仿真接口Router的名称标识           必选	      无        支持
# Ipv4Address    这个是仿真接口的IP地址       可选	      无        支持                 
# Ipv6Address	这个1*1的First RouteIPv6地址      可选	      无        支持 
# ConnectedName	 这个是TopRouter或TopNetwork的名称                                无        支持		
# NeiIpv4Address	这个是TopRouter或TopNetwork的IP		              无        支持
# NeiIpv6Address	邻居ipv6地址		                        不支持
# FlagTe	流量工程 		                                不支持
# FlagTag	标签	可选	                                        不支持
# FlagAdvertise	通告方式		                                支持    
# NarrowMetric	窄度量		                                        不支持
# WideMetric	宽度量	enable/diasble                                  支持
# MaxBandwith	最大带宽		                                不支持
# ReservableBandwith	预留带宽		                        不支持
# AdminGroup	管理组		                                        不支持
# UnreservedBw	无限制带宽		                                不支持
# LinkName	邻接名称		                                支持
#
# 语法描述:                                                         
#      isis ConfigTopRouterLink -routername toprouter1 -ipv4address 200.1.1.1 -neiipv4address 20.3.17.2 \
                             -flagadvertise enable
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::ConfigTopRouterLink {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigTopRouterLink...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  

    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routerName toprouter1
    set flagAdvetise "enable"
    set gridRows 1
    set gridCols 1
    set ipv4Address 200.1.1.1
    set addressFamily ipv4
    set startIpMask 24
    set wideMetric "disable"
    set neiipv4Address 201.1.1.1

    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]


    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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

#通过! 2009.7.23
#====================================================================
# 函数名称: AddTopNetwork  
# 函数编写: 杨卓 2009.6
# 功能描述: 为指定的ISIS Router创建ISIS网格拓扑； Ixia补充说明, 这里就是创建一个1*N的逻辑NetworkRange.
#           在后面要使用ConfigTopNetwork进行配置, 然后要使用AddTopRouterLink以及ConfigTopRouterLink把这个NetworkRange
#           和一个具体的仿真路由接口进行连接. 所以这个函数的作用仅仅就是接收用户参数输入,保存到一个数组中,
#           在使用ddTopRouterLink以及ConfigTopRouterLink的时候读入这些参数来创建真实的NetworkRange.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
#
# NetworkName	     ISIS Network的名称标识，    必选	      无        支持            
# AddressFamily	         IPV4 IPV6 Both		                        支持
# FirstAddress		                                                支持
# NumAddress                                             		支持
# Modifier	       每个网络变化的步长                     1	        支持	                        
# Prefixlen	      	                                      24        支持
# 					
#
# 语法描述:                                                         
#      IsisRouter1 AddTopNetwork -NetworkName Network1 \
#	    -FirstAddress 101.0.0.1 -NumAddress 20 \
#           -Prefixlen 32 \
#           -Modifier 1   \
#      
# 返回值：                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::AddTopNetwork {args} {
    ixDebugPuts "Enter proc IsisRouter::AddTopNetwork...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set networkName     topnetwork1
    set addressFamily   ipv4

    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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




#通过! 2009.7.23
#====================================================================
# 函数名称: ConfigTopNetwork  
# 函数编写: 杨卓 2009.6
# 功能描述: 为指定的ISIS Router创建ISIS网格拓扑； Ixia补充说明, 这里就是为已经创建的一个1*N的逻辑NetworkRange来修改参数.
#           然后要使用AddTopRouterLink以及ConfigTopRouterLink把这个NetworkRange
#           和一个具体的仿真路由接口进行连接. 所以这个函数的作用仅仅就是接收用户参数输入,保存到一个数组中,
#           在使用ddTopRouterLink以及ConfigTopRouterLink的时候读入这些参数来创建真实的NetworkRange.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
#
# NetworkName	     ISIS Network的名称标识，    必选	      无        支持            
# AddressFamily	         IPV4 IPV6 Both		                        支持
# FirstAddress		                                                支持
# NumAddress                                             		支持
# Modifier	       每个网络变化的步长                     1	        支持	                        
# Prefixlen	      	                                      24        支持
# 					
#
# 语法描述:                                                         
#      IsisRouter1 ConfigTopNetwork -NetworkName Network1 \
#	    -FirstAddress 102.0.0.1 -NumAddress 20 \
#           -Prefixlen 24 \
#           -Modifier 1   \
#      
# 返回值：                                                          
#      None                    
#====================================================================
itcl::body IsisRouter::ConfigTopNetwork {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigTopNetwork...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set networkName     topnetwork1
    set addressFamily   ipv4

    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称:RemoveTopNetwork  
# 函数编写: 杨卓 2009.6
# 功能描述: 删除指定的ISIS Grid；
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# GridName	ISIS Grid的名称标识，             必选                 支持
# 语法描述:                                                         
#      isis RemoveTopNetwork -networkname topnetwork1 
# 返回值：                                                          
#      none              
#====================================================================
itcl::body IsisRouter::RemoveTopNetwork {args} {
    ixDebugPuts "Enter proc IsisRouter::RemoveTopNetwork...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set networkName ""
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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

#通过! 2009.7.23
#====================================================================
# 函数名称:RemoveTopRouter 
# 函数编写: 杨卓 2009.6
# 功能描述: 删除指定的ISIS TopRouter；Ixia实现,就是删除已经存在的NetworkRange
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# Routername  	ISIS TopRouter的名称标识，             必选                 支持
# 语法描述:                                                         
#      isis RemoveTopRouter -routername toprouter1 
# 返回值：                                                          
#      none              
#====================================================================
itcl::body IsisRouter::RemoveTopRouter {args} {
    ixDebugPuts "Enter proc IsisRouter::RemoveTopRouter...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routerName ""
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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




#通过
#====================================================================
# 函数名称: CreateRouteBlock
# 函数编写: 杨卓 2009.4.2
# 功能描述: 为指定的ISIS Router 配置Isis路由块的参数；即为指定的路由器配置一个RouteRange.
# 根据和ZTE的确认.在Create和Config的时候,都要设置为Disable的状态,只有当Advertising的时候再设置为Enable的状态.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockName	    ISIS路由块的名称标识         必选	     无        支持
# RoutePoolType	    IPV4 IPV6 	                 必选	     IPV4       支持        
# FirstAddress	    起始地址	                 必选	     10.10.10.1 支持
#  PrefixLen	    掩码长度		         必选        24         支持
# NumAddress	    建立地址池中的地址数目	必选	     10         支持
# Modifier	    修正值, 即步长              必选	     1          不支持
# 语法描述:                                                         
#      isis AddGrid 
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::CreateRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::CreateRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockName     routeRange1
    set routePoolType ipv4
    set firstAddress  10.10.10.1 
    set prefixLen 24
    set numAddress 10
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称: CheckEssentialArgs
# 函数编写: 杨卓 2009.4.2
# 功能描述: 检查函数是否有必选参数没有输入.
# 语法描述:                                                         
#      CheckEssentialArgs $tmpList $essAgs 第一个参数是输入列表,第二个参数是必选参数列表
# 返回值：                                                          
#      成功返回0 失败返回1                  
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

#通过
#====================================================================
# 函数名称: ConfigRouteBlock
# 函数编写: 杨卓 2009.4.2
# 功能描述: 为指定的ISIS Router 配置Isis路由块的参数；即为指定的路由器配置一个RouteRange.
# 根据和ZTE的确认.在Create和Config的时候,都要设置为Disable的状态,只有当Advertising的时候再设置为Enable的状态.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockName	    已经存在的ISIS路由块的名称标识 必选	     无        支持     
# FirstAddress	    起始地址	                 必选	     10.10.10.1 支持
#  PrefixLen	    掩码长度		         必选        24         支持
# NumAddress	    建立地址池中的地址数目	必选	     10         支持
# Modifier	    修正值	                必选	     1          不支持
# 语法描述:                                                         
#      isis1 ConfigRouteBlock -blockname routeRange -FirstAddress 101.1.1.0 \
         -PrefixLen 24 -NumAddress 3 
# 返回值：                                                          
#      成功禁止 isis router 则返回1，否则返回0；                    
#====================================================================
itcl::body IsisRouter::ConfigRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::ConfigRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockName     routeRange1
    set routePoolType ipv4
    set firstAddress  10.10.10.1 
    set prefixLen 24
    set numAddress 10
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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




#通过
#====================================================================
# 函数名称: GetRouteBlock
# 函数编写: 杨卓 2009.4.2
# 功能描述:  列出该Router的绑定所有的地址池, 即打印出该RouteBlock的属性
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockNanme            ISIS路由块的名称           必选	     无        支持     
# 语法描述:                                                         
#      IsisRouter  GetRouteBlock -blockname routerange                                                
#                       
#====================================================================
itcl::body IsisRouter::GetRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::GetRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockNanmeList  routerange

    #这里是读入所有的args的值,并重新命名临时变量.
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

#通过
#====================================================================
# 函数名称: DeleteRouteBlock
# 函数编写: 杨卓 2009.4.2
# 功能描述:  删除指定ISIS Router的路由块, 即删除指定的路由器下的指定的RouteRange.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockName	    已经存在的ISIS路由块的名称标识 必选	     无        支持     
# 语法描述:                                                         
#      sisRouter  DeleteRouteBlock –BlockName routerange1                                                           
#                       
#====================================================================
itcl::body IsisRouter::DeleteRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::DeleteRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockName     routeRange1
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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



#通过
#====================================================================
# 函数名称: ListRouteBlock
# 函数编写: 杨卓 2009.4.2
# 功能描述:  列出该Router的绑定所有的地址池, 即打印出该ISISrouter下的所有的RouteRanges.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockNanmeList ISIS路由块的名称标识集合        必选	     无        支持     
# 语法描述:                                                         
#      IsisRouter  CreateRouteBlock -BlockNanmeList [list routeRange1 routeRange2]                                                    
#                       
#====================================================================
itcl::body IsisRouter::ListRouteBlock {args} {


    ixDebugPuts "Enter proc IsisRouter::ListRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockNanmeList     ""
    
    
    #这里是读入所有的args的值,并重新命名临时变量.
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
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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

#通过
#====================================================================
# 函数名称: AdvertiseRouteBlock
# 函数编写: 杨卓 2009.4.8
# 功能描述: 为指定的ISIS Router 的RouteRange开始Advertising.前提条件是用户
#           已经使用startRoute开始了这个路由仿真.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockName	    已经存在的ISIS路由块的名称标识 必选	     无        支持     
#
# 语法描述:                                                         
#      IsisRouter AdvertiseRouteBlock  –BlockName RouteRange1
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::AdvertiseRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::AdvertiseRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockName     routeRange1    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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

#通过
#====================================================================
# 函数名称: WithdrawRouteBlock
# 函数编写: 杨卓 2009.4.8
# 功能描述: 为指定的ISIS Router 的RouteRange 撤销已经广播的路由.前提条件是用户
#           已经使用startRoute开始了这个路由仿真.并且已经广播了路由.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# BlockName	    已经存在的ISIS路由块的名称标识 必选	     无        支持     
#
# 语法描述:                                                         
#      IsisRouter WithdrawRouteBlock  –BlockName RouteRange1
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::WithdrawRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::WithdrawRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set blockName     routeRange1    
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]
    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称: ConfigFlap 
# 函数编写: 杨卓 2009.5.5
# 功能描述: 该函数实现是震荡TopRouter和Grid,因为ISIS不支持TopRouter,所以这里就震荡GRID
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# AWDTimer     Advertise to Withdraw Delay  ms    必选	     无        支持     
# WADTimer     Withdraw toAdvertise Delay   ms    必选	     无        支持   
# 语法描述:                                                         
#     isisRouter ConfigFlapRouteBlock  –AWDTimer $time1 –WADTimerr $time2
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::ConfigFlap {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigFlap...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set awdTimer  60000 ;#60 seconds
    set wadTimer  60000
    
    #这里是读入所有的args的值,并重新命名临时变量.
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
# 函数名称: StartFlapRouters  
# 函数编写: 杨卓 2009.4.28
# 功能描述: 根据ZTE解释,该函数实现是震荡TopRouter和Grid的震荡,
#           因为Ixia的ISIS不支持TopRouter,所以这里就仅仅震荡一个Router下的所有存在的GRID
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持
# BlockName     ISIS路由块名称标识                 必选	     无        支持
# Flapinterval  每次震荡间隔时间      ms             必选      无        支持
# Flapnumber    震荡的次数                         必选      无        支持
# 语法描述:                                                         
#    Isisrouter1  StartFlapRoutes  –flapinterval 10000 –flapnumber 60000
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::StartFlapRouters {args} {
    ixDebugPuts "Enter proc IsisRouter::StartFlapRouters...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set Flapinterval  10000
    set Flapnumber  1
    
    #这里是读入所有的args的值,并重新命名临时变量.
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
# 函数名称: StopFlapRoutes 
# 函数编写: 杨卓 2009.5.5
# 功能描述:  停止振荡ISIS拓扑路由器
# 输入参数: No
# 语法描述:                                                         
#    Isisrouter1  StopFlapRouters
# 返回值：                                                          
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
# 函数名称: ConfigFlapRouteBlock 
# 函数编写: 杨卓 2009.4.28
# 功能描述: 配置该协议地址池的震荡频率
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# AWDTimer     Advertise to Withdraw Delay  ms    必选	     无        支持     
# WADTimer     Withdraw toAdvertise Delay   ms    必选	     无        支持   
# 语法描述:                                                         
#     isisRouter ConfigFlapRouteBlock  –AWDTimer $time1 –WADTimerr $time2
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::ConfigFlapRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::ConfigFlapRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set awdTimer  60000
    set wadTimer  60000
    
    #这里是读入所有的args的值,并重新命名临时变量.
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
# 函数名称: StartFlapRouteBlock  
# 函数编写: 杨卓 2009.4.28
# 功能描述: 震荡有Flap标志的地址池
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持
# BlockName     ISIS路由块名称标识                 必选	     无        支持
# Flapinterval  每次震荡间隔时间                   必选      无        支持
# Flapnumber    震荡的次数                         必选      无        支持
# 语法描述:                                                         
#    Isisrouter1  StartFlapRouteBlock –BlockName Blk1 –flapinterval $时间 –flapnumber $number
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::StartFlapRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::StartFlapRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set Flapinterval  30
    set Flapnumber  1
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]

    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称: StopFlapRouteBlock  
# 函数编写: 杨卓 2009.4.30
# 功能描述: 震荡有Flap标志的地址池
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持
# BlockName     ISIS路由块名称标识                 必选	     无        支持
# 语法描述:                                                         
#    Isisrouter1  StopFlapRouteBlock –BlockName Blk1 
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::StopFlapRouteBlock {args} {
    ixDebugPuts "Enter proc IsisRouter::StopFlapRouteBlock...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    
    #这里是读入所有的args的值,并重新命名临时变量.
    set tmpList    [lrange $args 0 end]
    set idxxx      0
    set tmpllength [llength $tmpList]

    #以下这一段判断是否所有的必选参数都在args中,如果没有,则报错退出.
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
# 函数名称:GetRouterStats
# 函数编写: 杨卓 2009.5.4
# 功能描述: 获取Isis相关统计结果
#
# 输入参数:
# 参数名称                 参数说明                参数类型       Ixia支持
#L1HelloPacketReceived	收到L1的Hello包                           yes
#L2HelloPacketReceived	收到L2的Hello包                           yes
#PtopHelloPacketReceived收到PtoP的Hello包                         yes
#L1LspPacketReceived	收到L1的Lsp包                             yes
#L2LspPacketReceived	收到L2的Lsp包                             yes  
#L1CsnpPacketReceived	收到L1的CSNP包                            yes
#L2CsnpPacketReceived	收到L2的CSNP包                            yes
#L1PsnpPacketReceived	收到L1的PSNP包                            yes
#L2PsnpPacketReceived	收到L2的PSNP包                            yes
#L1DatabaseSizeAdded	L1数据库增加                              no
#L2DatabaseSizeAdded	L2数据库增加                              no
#L1HelloPacketSent	发出L1的Hello包                           yes
#L2HelloPacketSent	发出L2的Hello包                           yes
#PtopHelloPacketSent	发出PtoP的Hello包                         yes
#L1LspPacketSent	发出L1的Lsp包                             yes
#L2LspPacketReceived	发出L2的Lsp包                             yes
#L1CsnpPacketSent	发出L1的CSNP包                            yes
#L2CsnpPacketSent	发出L2的CSNP包                            yes 
#L1PsnpPacketSent	发出L1的PSNP包                            yes
#L2PsnpPacketSent	发出L2的PSNP包                            yes
#L1DatabaseSizeRemoved	L1数据库减少                              no
#L2DatabaseSizeRemoved	L2数据库减少                              no

#
# 语法描述:                                                         
#    isis1 GetRouterStats –L1LspPacketReceived num
#
# 返回值：                                                          
#    打印每个可选参数的值,如本例中应该打印
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
# 函数名称:GraceRestartAction
# 函数编写: 杨卓 
# 功能描述:启动IsisRouter 的GR功能（主动方）
# 输入参数: 无
# 语法描述:                                                         
#    IsisRouter GraceRestartAction
# 返回值：                                                          
#    成功0，失败1；                         
#====================================================================
itcl::body IsisRouter::GraceRestartAction {args} {
        
    ixDebugPuts "Enter proc IsisRouter::GraceRestartAction...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值

    #这里是读入所有的args的值,并重新命名临时变量.
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

#未通过
#====================================================================
# 函数名称: AdvertiseRouters
# 函数编写: 杨卓 2009.4.23
# 功能描述: 通告ISIS拓扑路由器,Ixia解释:根据用户指定的已经创建的ISIS Grid名称来使能并广播路由.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# RouterNameList  已经存在的ISIS路由块的名称标识 必选	     无        支持     
#
# 语法描述:                                                         
#      IsisRouter AdvertiseRouters  -RouterNameList {grid1 grid2}
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::AdvertiseRouters {args} {
    ixDebugPuts "Enter proc IsisRouter::AdvertiseRouters...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routernamelist ""

    #这里是读入所有的args的值,并重新命名临时变量.
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

#未通过
#====================================================================
# 函数名称: WithdrawRouters
# 函数编写: 杨卓 2009.4.23
# 功能描述:  撤销ISIS拓扑路由器,Ixia解释:根据用户指定的已经创建的ISIS Grid名称来撤销路由.
# 输入参数:
# 参数名称              参数说明                  参数类型    默认值   Ixia支持     
# RouterNameList  已经存在的ISIS路由块的名称标识 必选	     无        支持     
#
# 语法描述:                                                         
#      IsisRouter WithdrawRouters  -RouterNameList {grid1 grid2}
# 返回值：                                                          
#                    
#====================================================================
itcl::body IsisRouter::WithdrawRouters {args} {
    ixDebugPuts "Enter proc IsisRouter::WithdrawRouters...\n"
    #这个函数的作用是根据用户的要求 "输入不区分大小写",所以将所有的args的输入都转化为小写的.
    set args     [ixConvertAllToLowerCase $args]
    puts "args: $args"
    #这个语句的作用是获取当前的过程名.
    set procname [lindex [info level [info level]] 0]  
    
    #读取输入参数并进行赋值
    #----------------------
    if {[catch {array set args_array $args} error]} {
        set ::ERRINFO  "$procname: $error."
        return $::FAILURE
    }
    #这里首先设定参数默认值
    set routernamelist ""
    
    #这里是读入所有的args的值,并重新命名临时变量.
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
# 函数名称: StartISISRouter
# 函数编写: 杨卓 2009.4.8
# 功能描述: 开始指定的Router的路由仿真
#           
# 输入参数: 无  
#
# 语法描述:                                                         
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